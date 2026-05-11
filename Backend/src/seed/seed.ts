/**
 * MEGA seeder TypeORM para FarmLink — simulación de 5 años de operación.
 *
 * Inserta:
 *   - 1 admin (admin@farmlink.com / admin123, bcrypt)
 *   - 3 fincas con nombres largos para probar overflow
 *   - 18 potreros (6/finca; uno con nombre extra-largo)
 *   - 375 bovinos (125/finca; pesos decimales; 80% hembras; ~24% vendidos)
 *   - 2250 movimientos (6/animal, distribuidos en su ventana de vida)
 *   - ~3375 registros de salud (mezcla vencidos/pendientes/al día + historia)
 *   - ~1100 finanzas distribuidas en 60 meses con tendencia creciente
 *   - 30 eventos reproductivos
 *
 * Diseño:
 *   - DataSource standalone (sin NestFactory) → más rápido, sin hooks.
 *   - Bulk insert vía QueryBuilder en chunks de 500.
 *   - TRUNCATE ... CASCADE al inicio para reset total y reset de secuencias.
 *
 * NOTA sobre nombres de columnas FK:
 *   `bovinos.fincaPkIdFinca` y `bovinos.potreroPkIdPotrero` son
 *   auto-generados por TypeORM (relaciones sin @JoinColumn — ver
 *   `animal.entity.ts:92-96`). El dashboard service ya usa estos nombres.
 */
import { DataSource } from 'typeorm';
import * as bcrypt from 'bcrypt';

import { Usuario, Rol } from '../usuarios/entities/usuario.entity';
import { Finca } from '../fincas/entities/finca.entity';
import { Potrero } from '../potreros/entities/potrero.entity';
import { Animal, EstadoAnimal, EtapaProductiva } from '../animales/entities/animal.entity';
import { MovimientoAnimal } from '../movimientos/entities/movimiento-animal.entity';
import { Salud } from '../salud/entities/salud.entity';
import { Finanza } from '../finanzas/entities/finanza.entity';
import { Reproduccion } from '../reproduccion/entities/reproduccion.entity';

const TENANT = 'tenant-demo';
const FINCAS_IDS = ['F1', 'F2', 'F3'] as const;
const ANIMALES_POR_FINCA = 125;
const MOVS_POR_ANIMAL = 6;
const HOY = new Date();

// ---------------- Helpers ----------------

function pick<T>(arr: readonly T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

function randInt(min: number, maxIncl: number): number {
  return Math.floor(Math.random() * (maxIncl - min + 1)) + min;
}

function randDecimal(min: number, max: number, decimals = 2): number {
  const v = Math.random() * (max - min) + min;
  const f = Math.pow(10, decimals);
  return Math.round(v * f) / f;
}

function randDateBetween(start: Date, end: Date): Date {
  const t = start.getTime() + Math.random() * (end.getTime() - start.getTime());
  return new Date(t);
}

function isoDate(d: Date): string {
  return d.toISOString().slice(0, 10);
}

function addDays(d: Date, days: number): Date {
  const r = new Date(d);
  r.setDate(r.getDate() + days);
  return r;
}

function addMonths(d: Date, months: number): Date {
  const r = new Date(d);
  r.setMonth(r.getMonth() + months);
  return r;
}

/**
 * Edad en meses entre dos fechas (floor). 0 si `to` <= `from`.
 * Usa 30.44 días/mes (promedio anual) para suavizar diferencias por mes.
 */
function monthsBetween(from: Date, to: Date): number {
  const ms = to.getTime() - from.getTime();
  return Math.max(0, Math.floor(ms / (1000 * 60 * 60 * 24 * 30.44)));
}

/**
 * Heurística extendida de etapa productiva (R6 + R10):
 *  - <24m → CRECIMIENTO.
 *  - Macho 12–24m en finca de engorde (F2) → ENGORDE.
 *  - Macho ≥24m de raza alta calidad (Brahman/Angus) con prob. 5% → REPRODUCTOR.
 *  - Hembra ≥24m → PRODUCCION.
 *  - Resto de machos ≥24m → SECA.
 */
function inferEtapa(
  genero: 'm' | 'h',
  edadMeses: number,
  finca: string,
  raza: RazaKey,
): EtapaProductiva {
  if (genero === 'm' && edadMeses >= 12 && edadMeses < 24 && finca === 'F2') {
    return EtapaProductiva.ENGORDE;
  }
  if (edadMeses < 24) return EtapaProductiva.CRECIMIENTO;
  if (genero === 'h') return EtapaProductiva.PRODUCCION;
  // Macho adulto.
  if ((raza === 'Brahman' || raza === 'Angus') && Math.random() < 0.05) {
    return EtapaProductiva.REPRODUCTOR;
  }
  return EtapaProductiva.SECA;
}

// Curvas zootécnicas aproximadas: peso al nacer, peso adulto por género
// (kg) y ganancia diaria promedio en gramos. Mantenidas conservadoras.
const RAZAS = {
  Brahman: { nacer: 32, adultoH: 480, adultoM: 720, gdpGr: 700 },
  Angus: { nacer: 30, adultoH: 550, adultoM: 800, gdpGr: 850 },
  Holstein: { nacer: 40, adultoH: 600, adultoM: 850, gdpGr: 750 },
  Jersey: { nacer: 25, adultoH: 420, adultoM: 600, gdpGr: 600 },
  Cebu: { nacer: 28, adultoH: 460, adultoM: 700, gdpGr: 680 },
  Romosinuano: { nacer: 30, adultoH: 470, adultoM: 680, gdpGr: 720 },
} as const;

type RazaKey = keyof typeof RAZAS;

/**
 * Peso coherente con edad y raza: crecimiento lineal desde el peso al
 * nacer hasta el peso adulto, con jitter ±8% para realismo. Garantiza
 * que un ternero no pese como un toro.
 */
function pesoPorEdadRaza(razaKey: RazaKey, genero: 'm' | 'h', edadMeses: number): number {
  const r = RAZAS[razaKey];
  const adulto = genero === 'h' ? r.adultoH : r.adultoM;
  const dias = edadMeses * 30.44;
  const lineal = r.nacer + (r.gdpGr / 1000) * dias;
  const cap = Math.min(lineal, adulto);
  const jitter = cap * (0.92 + Math.random() * 0.16);
  return Math.round(jitter * 100) / 100;
}

/**
 * Inserta `rows` en `chunks` de `size`. Devuelve la cantidad total insertada.
 * Usa createQueryBuilder().insert() para evitar hooks de TypeORM (más rápido).
 */
async function bulkInsert<T>(
  ds: DataSource,
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  entity: any,
  rows: T[],
  size = 500,
): Promise<number> {
  for (let i = 0; i < rows.length; i += size) {
    const chunk = rows.slice(i, i + size);
    await ds
      .createQueryBuilder()
      .insert()
      .into(entity)
      .values(chunk as object[])
      .execute();
  }
  return rows.length;
}

// ---------------- Fases ----------------

async function truncateAll(ds: DataSource): Promise<void> {
  console.log('[seed] 1/10 TRUNCATE de todas las tablas...');
  await ds.query(`
    TRUNCATE TABLE
      reproduccion,
      movimientos_animal,
      salud,
      finanzas,
      bovino_alimento,
      alimento,
      bovinos,
      potreros,
      finca,
      usuarios
    RESTART IDENTITY CASCADE;
  `);
}

async function seedAdmin(ds: DataSource): Promise<void> {
  console.log('[seed] 2/10 admin@farmlink.com (bcrypt admin123)...');
  const hash = bcrypt.hashSync('admin123', 10);
  await ds
    .createQueryBuilder()
    .insert()
    .into(Usuario)
    .values({
      email: 'admin@farmlink.com',
      password: hash,
      nombre: 'Camilo Anaya',
      rol: Rol.ADMIN,
      tenant_id: TENANT,
    })
    .execute();
}

async function seedFincas(ds: DataSource): Promise<void> {
  console.log('[seed] 3/10 3 fincas (nombres largos para probar overflow)...');
  const rows: Partial<Finca>[] = [
    {
      pk_id_finca: 'F1',
      nombre_finca: 'Hacienda Ganadera La Victoria del Sinú Medio S.A.S.',
      ubicacion: 'Tierralta, Córdoba',
      propietario: 'Camilo Anaya',
      area_total: 520.5,
      fecha_registro: new Date(2021, 0, 15),
      tenant_id: TENANT,
    },
    {
      pk_id_finca: 'F2',
      nombre_finca: 'Finca Vista Hermosa El Rincón Andino',
      ubicacion: 'Charalá, Santander',
      propietario: 'Camilo Anaya',
      area_total: 380.75,
      fecha_registro: new Date(2021, 2, 3),
      tenant_id: TENANT,
    },
    {
      pk_id_finca: 'F3',
      nombre_finca: 'El Oasis del Llano Oriental',
      ubicacion: 'Puerto Gaitán, Meta',
      propietario: 'Camilo Anaya',
      area_total: 1240.25,
      fecha_registro: new Date(2021, 5, 21),
      tenant_id: TENANT,
    },
  ];
  await bulkInsert(ds, Finca, rows);
}

async function seedPotreros(ds: DataSource): Promise<string[][]> {
  console.log('[seed] 4/10 18 potreros (6 por finca)...');
  const estados = ['activo', 'activo', 'activo', 'activo', 'en descanso', 'mantenimiento'];
  const nombresBase: Record<string, string[]> = {
    F1: [
      'Lote Alpha 1',
      'Lote Alpha 2',
      // Nombre extra-largo a propósito → probar truncado en farm_map_card.
      'Potrero Lote Alpha Sector Norte de la Hacienda — Zona de Levante 2024',
      'Pradera Sur',
      'El Mango',
      'Cerca del Río',
    ],
    F2: [
      'Sector Beta 1',
      'Sector Beta 2',
      'Sector Beta 3',
      'La Cumbre',
      'Vega Alta',
      'Llano Bajo',
    ],
    F3: [
      'Llano Charly 1',
      'Llano Charly 2',
      'Llano Charly 3',
      'Sabana Larga',
      'Caño Verde',
      'El Reposo',
    ],
  };
  const rows: Record<string, unknown>[] = [];
  const idsPorFinca: string[][] = [[], [], []];
  for (let fi = 0; fi < FINCAS_IDS.length; fi++) {
    const finca = FINCAS_IDS[fi];
    const prefix = ['POT-A', 'POT-B', 'POT-C'][fi];
    for (let j = 0; j < 6; j++) {
      const pid = `${prefix}${j + 1}`;
      idsPorFinca[fi].push(pid);
      rows.push({
        pk_id_potrero: pid,
        nombre_potrero: nombresBase[finca][j],
        area: randDecimal(15, 60, 2),
        capacidad_animales: randInt(50, 120),
        estado: estados[j],
        fecha_rotacion: randDateBetween(addMonths(HOY, -4), HOY),
        fecha_proxima_rotacion: addDays(HOY, randInt(15, 90)),
        tenant_id: TENANT,
        // FK declarada con @JoinColumn({name:'fk_id_finca'}) — el QueryBuilder
        // mapea solo por propiedad de la relación, no por nombre de columna.
        finca: { pk_id_finca: finca },
      });
    }
  }
  await bulkInsert(ds, Potrero, rows);
  return idsPorFinca;
}

interface BovinoSembrado {
  id: number;
  finca: string;
  potrero: string;
  fechaIngreso: Date;
  fechaSalida: Date | null;
  genero: 'm' | 'h';
  // True si el animal salió del inventario (VENDIDO o MUERTO). Lo usan
  // movimientos/reproducción para no generar eventos posteriores a la salida.
  inactivo: boolean;
}

async function seedBovinos(
  ds: DataSource,
  potrerosPorFinca: string[][],
): Promise<BovinoSembrado[]> {
  console.log(
    `[seed] 5/10 ${ANIMALES_POR_FINCA * FINCAS_IDS.length} bovinos (cronología y peso coherentes con edad/raza)...`,
  );
  const razaKeys = Object.keys(RAZAS) as RazaKey[];
  const rows: Record<string, unknown>[] = [];
  let bovIdx = 0;

  for (let fi = 0; fi < FINCAS_IDS.length; fi++) {
    const finca = FINCAS_IDS[fi];
    // Integridad de relaciones: el potrero asignado SIEMPRE pertenece
    // a esta finca (no se cruza ninguna FK entre F1/F2/F3).
    const potrerosDeEstaFinca = potrerosPorFinca[fi];
    for (let i = 0; i < ANIMALES_POR_FINCA; i++) {
      bovIdx++;
      const genero: 'm' | 'h' = Math.random() < 0.8 ? 'h' : 'm';
      const razaKey = pick(razaKeys);

      // Nacimiento distribuido 2018-2023 (mantiene mezcla joven/adulto).
      const fechaNacimiento = randDateBetween(
        new Date(2018, 0, 1),
        new Date(2023, 11, 31),
      );

      // R2/R3 — origen determina cómo se calcula fecha_ingreso.
      const origen = pick(['compra', 'nacimiento', 'compra'] as const);
      let fechaIngreso: Date;
      if (origen === 'nacimiento') {
        fechaIngreso = fechaNacimiento;
      } else {
        const minIng = addMonths(fechaNacimiento, 1);
        const maxIng = new Date(
          Math.min(
            addMonths(fechaNacimiento, 60).getTime(),
            addMonths(HOY, -2).getTime(),
          ),
        );
        fechaIngreso =
          maxIng.getTime() > minIng.getTime()
            ? randDateBetween(minIng, maxIng)
            : minIng;
      }

      // Estado del animal:
      //   R9 — 2% de probabilidad de MUERTO (precio/comprador null).
      //   R4 — primeros 30 índices candidatos a VENDIDO si llevan ≥6m.
      //   El resto, ACTIVO.
      // MUERTO tiene prioridad sobre VENDIDO (un animal muerto no se vende).
      const seisMesesDesdeIngreso = addMonths(fechaIngreso, 6);
      const cumpleVentana = seisMesesDesdeIngreso.getTime() < HOY.getTime();
      const muerto = cumpleVentana && Math.random() < 0.02;
      const vendido = !muerto && i < 30 && cumpleVentana;
      let estado: EstadoAnimal = EstadoAnimal.ACTIVO;
      let fechaSalida: Date | null = null;
      if (muerto) {
        estado = EstadoAnimal.MUERTO;
        fechaSalida = randDateBetween(seisMesesDesdeIngreso, HOY);
      } else if (vendido) {
        estado = EstadoAnimal.VENDIDO;
        fechaSalida = randDateBetween(seisMesesDesdeIngreso, HOY);
      }

      // R6/R7 — edad al corte (fecha_salida si tiene, HOY si activo).
      const fechaCorte = fechaSalida ?? HOY;
      const edadMeses = monthsBetween(fechaNacimiento, fechaCorte);
      // R10 — etapa puede ser ENGORDE (macho 12-24m en F2) o
      // REPRODUCTOR (macho ≥24m, raza Brahman/Angus, prob. 5%).
      const etapa = inferEtapa(genero, edadMeses, finca, razaKey);

      // R8 — peso coherente con edad y raza.
      const peso = pesoPorEdadRaza(razaKey, genero, edadMeses);

      rows.push({
        numero_identificacion: `BOV-${bovIdx}`,
        fecha_nacimiento: isoDate(fechaNacimiento),
        edad_actual: edadMeses,
        genero,
        peso,
        raza: razaKey,
        origen,
        fecha_ingreso: isoDate(fechaIngreso),
        fecha_salida: fechaSalida ? isoDate(fechaSalida) : null,
        etapa_productiva: etapa,
        estado,
        // R5/R9 — solo VENDIDO tiene precio_venta y comprador.
        precio_venta: estado === EstadoAnimal.VENDIDO ? randDecimal(1_800_000, 4_500_000, 2) : null,
        comprador: estado === EstadoAnimal.VENDIDO ? 'Frigorífico Demo S.A.S.' : null,
        tenant_id: TENANT,
        // Las columnas FK son auto-generadas por TypeORM como
        // `fincaPkIdFinca` / `potreroPkIdPotrero`, pero el QueryBuilder
        // las mapea solo a través de la propiedad de la relación. Pasar
        // las columnas planas con esos nombres NO funciona — quedan
        // como NULL en la BD. La forma correcta es pasar el objeto
        // parcial de la relación con el PK referenciado.
        finca: { pk_id_finca: finca },
        potrero: { pk_id_potrero: pick(potrerosDeEstaFinca) },
      });
    }
  }

  // Inserción con RETURNING id para capturar las PKs auto-generadas en orden.
  const idsCapturados: number[] = [];
  const chunkSize = 200;
  for (let i = 0; i < rows.length; i += chunkSize) {
    const chunk = rows.slice(i, i + chunkSize);
    const result = await ds
      .createQueryBuilder()
      .insert()
      .into(Animal)
      .values(chunk as object[])
      .returning(['id'])
      .execute();
    // result.raw es un array de { id: number } (Postgres devuelve en orden).
    for (const r of result.raw as { id: number }[]) idsCapturados.push(r.id);
  }

  // Reconstruir el array de BovinoSembrado emparejando por índice
  // (el orden de RETURNING coincide con el de VALUES en Postgres).
  const sembrados: BovinoSembrado[] = [];
  for (let i = 0; i < rows.length; i++) {
    const r = rows[i];
    sembrados.push({
      id: idsCapturados[i],
      finca: (r.finca as { pk_id_finca: string }).pk_id_finca,
      potrero: (r.potrero as { pk_id_potrero: string }).pk_id_potrero,
      fechaIngreso: new Date(r.fecha_ingreso as string),
      fechaSalida: r.fecha_salida ? new Date(r.fecha_salida as string) : null,
      genero: r.genero as 'm' | 'h',
      inactivo: r.estado !== EstadoAnimal.ACTIVO,
    });
  }
  return sembrados;
}

async function seedMovimientos(
  ds: DataSource,
  bovinos: BovinoSembrado[],
  potrerosPorFinca: string[][],
): Promise<number> {
  console.log(`[seed] 6/10 ${bovinos.length * MOVS_POR_ANIMAL} movimientos (trazabilidad)...`);
  const motivos = [
    'Rotación de pastoreo',
    'Reagrupación por etapa',
    'Aislamiento sanitario',
    'Cambio por sobrepastoreo',
    'Reagrupación reproductiva',
    'Movimiento por inundación',
    'Rotación programada',
    'Separación por edad',
  ];
  const fincaIdx: Record<string, number> = { F1: 0, F2: 1, F3: 2 };
  const rows: Record<string, unknown>[] = [];

  for (const b of bovinos) {
    const potreros = potrerosPorFinca[fincaIdx[b.finca]];
    const desde = b.fechaIngreso;
    const hasta = b.fechaSalida ?? HOY;
    if (hasta.getTime() <= desde.getTime()) continue;
    let origen = b.potrero;
    for (let m = 0; m < MOVS_POR_ANIMAL; m++) {
      const fraccion = (m + 1) / (MOVS_POR_ANIMAL + 1);
      const tMov = desde.getTime() + fraccion * (hasta.getTime() - desde.getTime());
      const fecha = new Date(tMov);
      // Destino aleatorio distinto al origen actual.
      let destino = pick(potreros);
      let safety = 4;
      while (destino === origen && safety-- > 0) destino = pick(potreros);
      rows.push({
        fecha: isoDate(fecha),
        motivo: pick(motivos),
        tenant_id: TENANT,
        animal: { id: b.id },
        potreroOrigen: { pk_id_potrero: origen },
        potreroDestino: { pk_id_potrero: destino },
      });
      origen = destino;
    }
  }

  await bulkInsert(ds, MovimientoAnimal, rows, 500);
  return rows.length;
}

interface SaludCounts {
  vencidos: number;
  pendientes: number;
  alDia: number;
  historicos: number;
}

async function seedSalud(
  ds: DataSource,
  bovinos: BovinoSembrado[],
): Promise<SaludCounts> {
  console.log('[seed] 7/10 salud (vencidos / pendientes / al día + historial 5y)...');
  const tipos = ['vacunacion', 'vitaminas', 'desparasitacion', 'enfermedad'];
  const productos = [
    'Aftosa',
    'Brucelosis',
    'Ivermectina',
    'Vitamina B12',
    'Antiparasitario',
    'Triple bovina',
    'Bacterina',
  ];
  const rows: Record<string, unknown>[] = [];
  const counts: SaludCounts = { vencidos: 0, pendientes: 0, alDia: 0, historicos: 0 };

  for (const b of bovinos) {
    const r = Math.random();
    let proximaOff: number;
    if (r < 0.3) {
      proximaOff = -randInt(1, 60); // vencido
      counts.vencidos++;
    } else if (r < 0.5) {
      proximaOff = randInt(1, 14); // pendiente
      counts.pendientes++;
    } else {
      proximaOff = randInt(45, 365); // al día
      counts.alDia++;
    }
    const proxima = addDays(HOY, proximaOff);
    const aplicacion = addDays(proxima, -randInt(120, 240));
    rows.push({
      tipo_intervencion: pick(tipos),
      producto_aplicado: pick(productos),
      fecha_aplicacion: isoDate(aplicacion),
      fecha_proxima_aplicacion: isoDate(proxima),
      costo: randDecimal(15000, 85000, 2),
      tenant_id: TENANT,
      animal: { id: b.id },
    });

    // 2 registros históricos extras distribuidos en su ventana de vida
    // — alimenta el sparkline `salud` del Bento.
    const vidaInicio = b.fechaIngreso;
    const vidaFin = b.fechaSalida ?? HOY;
    for (let h = 0; h < 2; h++) {
      const apl = randDateBetween(vidaInicio, vidaFin);
      rows.push({
        tipo_intervencion: pick(tipos),
        producto_aplicado: pick(productos),
        fecha_aplicacion: isoDate(apl),
        fecha_proxima_aplicacion: isoDate(addDays(apl, randInt(60, 240))),
        costo: randDecimal(12000, 95000, 2),
        tenant_id: TENANT,
        animal: { id: b.id },
      });
      counts.historicos++;
    }
  }

  await bulkInsert(ds, Salud, rows, 500);
  return counts;
}

async function seedFinanzas(ds: DataSource): Promise<{ ingresos: number; gastos: number }> {
  console.log('[seed] 8/10 finanzas (60 meses × 3 fincas, tendencia creciente)...');
  const ingresoConceptos = [
    ['Venta de leche', 'venta_leche'],
    ['Venta de novillos', 'venta_ganado'],
    ['Venta de quesos artesanales', 'venta_leche'],
  ];
  const gastoConceptos = [
    ['Nómina de vaqueros', 'nomina'],
    ['Insumos agropecuarios', 'insumos'],
    ['Alimento concentrado', 'alimento'],
    ['Veterinaria y medicina', 'veterinaria'],
    ['Mantenimiento de cercas', 'insumos'],
  ];

  const rows: Record<string, unknown>[] = [];
  let seq = 0;
  let ingresos = 0;
  let gastos = 0;

  for (let year = 2021; year <= 2026; year++) {
    const yearFactor = 1 + 0.08 * (year - 2021);
    const lastMonth = year === 2026 ? 4 : 12;
    for (let month = 1; month <= lastMonth; month++) {
      const ingresosFactor = month === 10 || month === 11 ? 1.4 : 1;
      const gastosFactor = month === 3 || month === 4 ? 1.3 : 1;
      for (const finca of FINCAS_IDS) {
        const movs = randInt(4, 7);
        for (let k = 0; k < movs; k++) {
          const day = randInt(1, 27);
          const fecha = new Date(year, month - 1, day);
          const esIngreso = Math.random() < 0.5;
          if (esIngreso) {
            const [concepto, categoria] = pick(ingresoConceptos);
            const monto = randDecimal(2_500_000, 15_000_000, 2) * yearFactor * ingresosFactor;
            rows.push({
              pk_id_finanza: `FIN-${++seq}`,
              tipo_movimiento: 'ingreso',
              concepto,
              categoria,
              monto: Math.round(monto * 100) / 100,
              fecha: isoDate(fecha),
              tenant_id: TENANT,
              finca: { pk_id_finca: finca },
            });
            ingresos++;
          } else {
            const [concepto, categoria] = pick(gastoConceptos);
            const monto = randDecimal(300_000, 3_800_000, 2) * yearFactor * gastosFactor;
            rows.push({
              pk_id_finanza: `FIN-${++seq}`,
              tipo_movimiento: 'gasto',
              concepto,
              categoria,
              monto: Math.round(monto * 100) / 100,
              fecha: isoDate(fecha),
              tenant_id: TENANT,
              finca: { pk_id_finca: finca },
            });
            gastos++;
          }
        }
      }
    }
  }

  await bulkInsert(ds, Finanza, rows, 500);
  return { ingresos, gastos };
}

async function seedReproduccion(
  ds: DataSource,
  bovinos: BovinoSembrado[],
): Promise<number> {
  console.log('[seed] 9/10 reproduccion (30 eventos)...');
  const hembras = bovinos.filter((b) => b.genero === 'h' && !b.inactivo).slice(0, 30);
  const rows: Record<string, unknown>[] = [];
  hembras.forEach((b, i) => {
    const enCelo = i % 3 === 0;
    rows.push({
      pk_id_reproduccion: `REP-${i + 1}`,
      // fk_id_madre es VARCHAR(15); el dashboard service hace b.id::text = r.fk_id_madre.
      fk_id_madre: String(b.id),
      metodo_reproduccion: enCelo ? 'monta_natural' : 'inseminacion',
      en_celo: enCelo,
      preñada: !enCelo,
      numero_crias: enCelo ? null : 1,
      fecha_estimado_parto: enCelo
        ? null
        : isoDate(addDays(HOY, randInt(30, 270))),
      tenant_id: TENANT,
    });
  });
  await bulkInsert(ds, Reproduccion, rows);
  return rows.length;
}

// ---------------- Orquestador ----------------

export async function runSeed(ds: DataSource): Promise<void> {
  await truncateAll(ds);
  await seedAdmin(ds);
  await seedFincas(ds);
  const potrerosPorFinca = await seedPotreros(ds);
  const bovinos = await seedBovinos(ds, potrerosPorFinca);
  const nMovs = await seedMovimientos(ds, bovinos, potrerosPorFinca);
  const salud = await seedSalud(ds, bovinos);
  const finanzas = await seedFinanzas(ds);
  const nRepro = await seedReproduccion(ds, bovinos);

  console.log('[seed] 10/10 resumen');
  console.log('+----------------------------------------------------+');
  console.log('|         FARMLINK — SIMULACIÓN 5 AÑOS               |');
  console.log('+----------------------------------------------------+');
  console.log(`  Fincas........................: ${FINCAS_IDS.length}`);
  console.log(`  Potreros......................: ${potrerosPorFinca.flat().length}`);
  console.log(`  Bovinos.......................: ${bovinos.length}`);
  console.log(`  Movimientos...................: ${nMovs}`);
  console.log(`  Salud — vencidos..............: ${salud.vencidos}`);
  console.log(`  Salud — pendientes............: ${salud.pendientes}`);
  console.log(`  Salud — al día................: ${salud.alDia}`);
  console.log(`  Salud — históricos extra......: ${salud.historicos}`);
  console.log(`  Finanzas — ingresos...........: ${finanzas.ingresos}`);
  console.log(`  Finanzas — gastos.............: ${finanzas.gastos}`);
  console.log(`  Reproducción..................: ${nRepro}`);
  console.log('+----------------------------------------------------+');
}
