import { Test, TestingModule } from '@nestjs/testing';
import {
  INestApplication,
  ValidationPipe,
  ClassSerializerInterceptor,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import request from 'supertest';
import * as cookieParser from 'cookie-parser';

import { AppModule } from '../src/app.module';
import { GlobalHttpExceptionFilter } from '../src/common/filters/http-exception.filter';
import { Finca } from '../src/fincas/entities/finca.entity';
import {
  Animal,
  EstadoAnimal,
  EtapaProductiva,
} from '../src/animales/entities/animal.entity';
import { Alimento } from '../src/alimentos/entities/alimento.entity';
import { BovinoAlimento } from '../src/bovino-alimento/entities/bovino-alimento.entity';
import { Finanza } from '../src/finanzas/entities/finanza.entity';
import { Usuario } from '../src/usuarios/entities/usuario.entity';

jest.setTimeout(30_000);

// Identificadores únicos por test run para no chocar con seed manual ni con
// runs concurrentes en la misma base de datos de dev.
// SHORT (base36) cabe en columnas pk_id_* de length:15.
const RUN = Date.now();
const SHORT = RUN.toString(36);
const TENANT_A = `t-iso-a-${SHORT}`;
const TENANT_B = `t-iso-b-${SHORT}`;
const FINCA_A = `FA-${SHORT}`;
const FINCA_B = `FB-${SHORT}`;
const ALIMENTO_A = `AA-${SHORT}`;
const ALIMENTO_B = `AB-${SHORT}`;
const FINANZA_A = `FZA-${SHORT}`;
const FINANZA_B = `FZB-${SHORT}`;
const EMAIL_A = `iso-a-${SHORT}@test.com`;
const EMAIL_B = `iso-b-${SHORT}@test.com`;
const PASSWORD = 'TestPass123';

// Replica los globales de src/main.ts. Sin esto los 404 no pasan por el
// GlobalHttpExceptionFilter (la respuesta no tiene `message` estandarizado)
// y la ValidationPipe no aplica a los DTOs.
async function bootstrapTestApp(): Promise<INestApplication> {
  const moduleFixture: TestingModule = await Test.createTestingModule({
    imports: [AppModule],
  }).compile();

  const app = moduleFixture.createNestApplication();
  app.use((cookieParser as any).default());
  app.setGlobalPrefix('api');
  app.useGlobalFilters(new GlobalHttpExceptionFilter());
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );
  app.useGlobalInterceptors(new ClassSerializerInterceptor(app.get(Reflector)));

  await app.init();
  return app;
}

describe('Dashboard multi-tenant isolation (e2e)', () => {
  let app: INestApplication;

  let fincaRepo: Repository<Finca>;
  let animalRepo: Repository<Animal>;
  let alimentoRepo: Repository<Alimento>;
  let bovinoAlimentoRepo: Repository<BovinoAlimento>;
  let finanzaRepo: Repository<Finanza>;
  let usuarioRepo: Repository<Usuario>;

  let JWT_A: string;
  let JWT_B: string;

  beforeAll(async () => {
    app = await bootstrapTestApp();

    fincaRepo = app.get<Repository<Finca>>(getRepositoryToken(Finca));
    animalRepo = app.get<Repository<Animal>>(getRepositoryToken(Animal));
    alimentoRepo = app.get<Repository<Alimento>>(getRepositoryToken(Alimento));
    bovinoAlimentoRepo = app.get<Repository<BovinoAlimento>>(
      getRepositoryToken(BovinoAlimento),
    );
    finanzaRepo = app.get<Repository<Finanza>>(getRepositoryToken(Finanza));
    usuarioRepo = app.get<Repository<Usuario>>(getRepositoryToken(Usuario));

    // 1) Registro de usuarios vía API (hash bcrypt + validación de unicidad).
    await request(app.getHttpServer())
      .post('/api/auth/registro')
      .send({
        email: EMAIL_A,
        password: PASSWORD,
        nombre: 'Iso A',
        tenant_id: TENANT_A,
      })
      .expect(201);

    await request(app.getHttpServer())
      .post('/api/auth/registro')
      .send({
        email: EMAIL_B,
        password: PASSWORD,
        nombre: 'Iso B',
        tenant_id: TENANT_B,
      })
      .expect(201);

    // 2) Login para obtener access_token.
    const loginA = await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: EMAIL_A, password: PASSWORD })
      .expect(200);
    JWT_A = loginA.body.access_token;

    const loginB = await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: EMAIL_B, password: PASSWORD })
      .expect(200);
    JWT_B = loginB.body.access_token;

    // 3) Sembrado de dominio por tenant vía repositorios. No usamos la API
    //    porque requeriría implementar (y autenticar) endpoints de creación
    //    de cada recurso — el foco del test es el aislamiento del dashboard,
    //    no del CRUD.
    const fincaA = await fincaRepo.save(
      fincaRepo.create({
        pk_id_finca: FINCA_A,
        nombre_finca: 'Finca Iso A',
        tenant_id: TENANT_A,
      }),
    );
    const fincaB = await fincaRepo.save(
      fincaRepo.create({
        pk_id_finca: FINCA_B,
        nombre_finca: 'Finca Iso B',
        tenant_id: TENANT_B,
      }),
    );

    const animalA = await animalRepo.save(
      animalRepo.create({
        numero_identificacion: `A-${SHORT}`,
        fecha_nacimiento: new Date('2023-01-01') as any,
        genero: 'h',
        peso: 350.5,
        raza: 'Brahman',
        etapa_productiva: EtapaProductiva.PRODUCCION,
        estado: EstadoAnimal.ACTIVO,
        tenant_id: TENANT_A,
        finca: fincaA,
      }),
    );

    const animalB = await animalRepo.save(
      animalRepo.create({
        numero_identificacion: `B-${SHORT}`,
        fecha_nacimiento: new Date('2023-01-01') as any,
        genero: 'h',
        peso: 360.0,
        raza: 'Brahman',
        etapa_productiva: EtapaProductiva.PRODUCCION,
        estado: EstadoAnimal.ACTIVO,
        tenant_id: TENANT_B,
        finca: fincaB,
      }),
    );

    // Costos muy distintos entre tenants — si un JOIN sin filtro de tenant
    // mezclara los datos, el assert detectaría la fuga inmediatamente.
    await alimentoRepo.save(
      alimentoRepo.create({
        pk_id_alimento: ALIMENTO_A,
        tipo_alimento: 'Concentrado A',
        cantidad_total: 100,
        costo: 5000,
        tenant_id: TENANT_A,
      }),
    );
    await alimentoRepo.save(
      alimentoRepo.create({
        pk_id_alimento: ALIMENTO_B,
        tipo_alimento: 'Concentrado B',
        cantidad_total: 100,
        costo: 99999,
        tenant_id: TENANT_B,
      }),
    );

    await bovinoAlimentoRepo.save(
      bovinoAlimentoRepo.create({
        fk_id_bovino: animalA.id,
        fk_id_alimento: ALIMENTO_A,
        cantidad: 100,
        fecha: new Date() as any,
        tenant_id: TENANT_A,
      }),
    );
    await bovinoAlimentoRepo.save(
      bovinoAlimentoRepo.create({
        fk_id_bovino: animalB.id,
        fk_id_alimento: ALIMENTO_B,
        cantidad: 100,
        fecha: new Date() as any,
        tenant_id: TENANT_B,
      }),
    );

    await finanzaRepo.save(
      finanzaRepo.create({
        pk_id_finanza: FINANZA_A,
        tipo_movimiento: 'ingreso',
        monto: 100,
        fecha: new Date() as any,
        tenant_id: TENANT_A,
        finca: fincaA,
      }),
    );
    await finanzaRepo.save(
      finanzaRepo.create({
        pk_id_finanza: FINANZA_B,
        tipo_movimiento: 'ingreso',
        monto: 999,
        fecha: new Date() as any,
        tenant_id: TENANT_B,
        finca: fincaB,
      }),
    );
  });

  afterAll(async () => {
    if (!app) return;
    const tenants = [TENANT_A, TENANT_B];

    // Hard delete en orden FK-safe: tabla de unión → dependientes →
    // bovinos/alimentos → fincas → usuarios.
    await bovinoAlimentoRepo
      .createQueryBuilder()
      .delete()
      .where('tenant_id IN (:...tenants)', { tenants })
      .execute();
    await finanzaRepo
      .createQueryBuilder()
      .delete()
      .where('tenant_id IN (:...tenants)', { tenants })
      .execute();
    await animalRepo
      .createQueryBuilder()
      .delete()
      .where('tenant_id IN (:...tenants)', { tenants })
      .execute();
    await alimentoRepo
      .createQueryBuilder()
      .delete()
      .where('tenant_id IN (:...tenants)', { tenants })
      .execute();
    await fincaRepo
      .createQueryBuilder()
      .delete()
      .where('tenant_id IN (:...tenants)', { tenants })
      .execute();
    await usuarioRepo
      .createQueryBuilder()
      .delete()
      .where('tenant_id IN (:...tenants)', { tenants })
      .execute();

    await app.close();
  });

  // ===================================================================
  // Escenarios
  // ===================================================================

  it('1. legítimo: dashboard global del Tenant A devuelve solo sus datos', async () => {
    const res = await request(app.getHttpServer())
      .get('/api/dashboard/summary')
      .set('Authorization', `Bearer ${JWT_A}`)
      .expect(200);

    expect(res.body.demography.total).toBeGreaterThanOrEqual(1);
    expect(res.body.finances_summary.total_ingresos).toBe(100);
    // El monto del Tenant B (999) NUNCA debe aparecer.
    expect(res.body.finances_summary.total_ingresos).not.toBe(999);
    expect(res.body.finances_summary.total_ingresos).not.toBe(1099);
  });

  it('2. legítimo: dashboard filtrado por Finca_A con JWT_A devuelve 200', async () => {
    const res = await request(app.getHttpServer())
      .get(`/api/dashboard/summary?fincaId=${FINCA_A}`)
      .set('Authorization', `Bearer ${JWT_A}`)
      .expect(200);

    expect(res.body.demography.total).toBeGreaterThanOrEqual(1);
    expect(res.body.finances_summary.total_ingresos).toBe(100);
  });

  it('3. cross-tenant (SEC-2): JWT_A pidiendo Finca_B → 404', async () => {
    const res = await request(app.getHttpServer())
      .get(`/api/dashboard/summary?fincaId=${FINCA_B}`)
      .set('Authorization', `Bearer ${JWT_A}`)
      .expect(404);

    expect(res.body.message).toBe('Finca no encontrada');
  });

  it('4. finca inexistente: JWT_A con id random → 404', async () => {
    await request(app.getHttpServer())
      .get(`/api/dashboard/summary?fincaId=NOEXIST-${SHORT}`)
      .set('Authorization', `Bearer ${JWT_A}`)
      .expect(404);
  });

  it('5. aislamiento de costos (SEC-1): A no incluye Alimento de B', async () => {
    const [resA, resB] = await Promise.all([
      request(app.getHttpServer())
        .get('/api/dashboard/inteligencia')
        .set('Authorization', `Bearer ${JWT_A}`)
        .expect(200),
      request(app.getHttpServer())
        .get('/api/dashboard/inteligencia')
        .set('Authorization', `Bearer ${JWT_B}`)
        .expect(200),
    ]);

    const costoA = resA.body.costo_total_animales.costo_alimentacion;
    const costoB = resB.body.costo_total_animales.costo_alimentacion;

    // Sembramos costos muy distintos (5000 vs 99999). Si un JOIN sin filtro
    // de tenant_id mezclara los datos, costoA contendría parte de 99999.
    expect(costoA).toBeCloseTo(5000, 0);
    expect(costoB).toBeCloseTo(99999, 0);
    expect(costoA).not.toBe(costoB);
  });

  it('6. aislamiento de finanzas sin filtro: JWT_A no ve la Finanza_B', async () => {
    const res = await request(app.getHttpServer())
      .get('/api/dashboard/summary')
      .set('Authorization', `Bearer ${JWT_A}`)
      .expect(200);

    expect(res.body.finances_summary.total_ingresos).toBe(100);
    expect(res.body.finances_summary.total_ingresos).not.toBe(999);
    expect(res.body.finances_summary.total_ingresos).not.toBe(1099);
  });

  it('7. sin auth → 401', async () => {
    await request(app.getHttpServer()).get('/api/dashboard/summary').expect(401);
  });
});
