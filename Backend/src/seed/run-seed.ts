/**
 * Entry point del seeder MEGA. Ejecutado por `npm run seed`.
 *
 * - Carga `.env` para leer la conexión Postgres (mismas vars que el CLI
 *   de TypeORM: DB_HOST, DB_PORT, DB_USERNAME, DB_PASSWORD, DB_DATABASE).
 * - Inicializa el `AppDataSource` ya declarado en
 *   `src/config/typeorm-cli.config.ts` para reutilizar la lista de
 *   entidades; así si un día se agrega/borra una entidad, el seeder no
 *   necesita actualizarse.
 * - Delega en `runSeed(ds)` la lógica completa.
 * - Cierra la conexión siempre, incluso si la siembra falla.
 */
import 'reflect-metadata';
import { config as loadEnv } from 'dotenv';
loadEnv();

import { AppDataSource } from '../config/typeorm-cli.config';
import { runSeed } from './seed';

async function main(): Promise<void> {
  const t0 = Date.now();
  await AppDataSource.initialize();
  try {
    await runSeed(AppDataSource);
    const secs = ((Date.now() - t0) / 1000).toFixed(1);
    console.log(`\n[seed] OK en ${secs}s`);
  } finally {
    await AppDataSource.destroy();
  }
}

main().catch((err) => {
  console.error('\n[seed] FAILED');
  console.error(err);
  process.exit(1);
});
