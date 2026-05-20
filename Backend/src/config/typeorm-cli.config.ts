import 'reflect-metadata';
import { DataSource } from 'typeorm';
import { config as loadEnv } from 'dotenv';

import { Usuario } from '../usuarios/entities/usuario.entity';
import { Finca } from '../fincas/entities/finca.entity';
import { Animal } from '../animales/entities/animal.entity';
import { Potrero } from '../potreros/entities/potrero.entity';
import { Alimento } from '../alimentos/entities/alimento.entity';
import { Salud } from '../salud/entities/salud.entity';
import { Reproduccion } from '../reproduccion/entities/reproduccion.entity';
import { Finanza } from '../finanzas/entities/finanza.entity';
import { BovinoAlimento } from '../bovino-alimento/entities/bovino-alimento.entity';
import { MovimientoAnimal } from '../movimientos/entities/movimiento-animal.entity';
import { Veterinario } from '../veterinarios/entities/veterinario.entity';
import { Cita } from '../citas/entities/cita.entity';
import { Tratamiento, SeguimientoTratamiento } from '../tratamientos/entities/tratamiento.entity';

// DataSource usado SOLO por el CLI de TypeORM (migration:generate / migration:run).
// La app en runtime sigue inicializándose con TypeOrmModule.forRootAsync en
// app.module.ts — este archivo no se importa desde el bootstrap de Nest.
loadEnv();

export const AppDataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST,
  port: +(process.env.DB_PORT ?? '5433'),
  username: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE,
  entities: [
    Usuario,
    Finca,
    Animal,
    Potrero,
    Alimento,
    Salud,
    Reproduccion,
    Finanza,
    BovinoAlimento,
    MovimientoAnimal,
    Veterinario,
    Cita,
    Tratamiento,
    SeguimientoTratamiento,
  ],
  migrations: ['src/migrations/*.ts'],
  synchronize: false,
  migrationsTableName: 'typeorm_migrations',
});
