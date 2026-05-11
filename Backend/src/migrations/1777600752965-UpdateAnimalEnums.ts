import { MigrationInterface, QueryRunner } from "typeorm";

export class UpdateAnimalEnums1777600752965 implements MigrationInterface {
    name = 'UpdateAnimalEnums1777600752965'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TYPE "public"."bovinos_etapa_productiva_enum" RENAME TO "bovinos_etapa_productiva_enum_old"`);
        await queryRunner.query(`CREATE TYPE "public"."bovinos_etapa_productiva_enum" AS ENUM('produccion', 'crecimiento', 'seca', 'engorde', 'reproductor', 'sin_clasificar')`);
        await queryRunner.query(`ALTER TABLE "bovinos" ALTER COLUMN "etapa_productiva" DROP DEFAULT`);
        await queryRunner.query(`ALTER TABLE "bovinos" ALTER COLUMN "etapa_productiva" TYPE "public"."bovinos_etapa_productiva_enum" USING "etapa_productiva"::"text"::"public"."bovinos_etapa_productiva_enum"`);
        await queryRunner.query(`ALTER TABLE "bovinos" ALTER COLUMN "etapa_productiva" SET DEFAULT 'sin_clasificar'`);
        await queryRunner.query(`DROP TYPE "public"."bovinos_etapa_productiva_enum_old"`);
        await queryRunner.query(`ALTER TYPE "public"."bovinos_estado_enum" RENAME TO "bovinos_estado_enum_old"`);
        await queryRunner.query(`CREATE TYPE "public"."bovinos_estado_enum" AS ENUM('activo', 'vendido', 'muerto')`);
        await queryRunner.query(`ALTER TABLE "bovinos" ALTER COLUMN "estado" DROP DEFAULT`);
        await queryRunner.query(`ALTER TABLE "bovinos" ALTER COLUMN "estado" TYPE "public"."bovinos_estado_enum" USING "estado"::"text"::"public"."bovinos_estado_enum"`);
        await queryRunner.query(`ALTER TABLE "bovinos" ALTER COLUMN "estado" SET DEFAULT 'activo'`);
        await queryRunner.query(`DROP TYPE "public"."bovinos_estado_enum_old"`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TYPE "public"."bovinos_estado_enum_old" AS ENUM('activo', 'vendido')`);
        await queryRunner.query(`ALTER TABLE "bovinos" ALTER COLUMN "estado" DROP DEFAULT`);
        await queryRunner.query(`ALTER TABLE "bovinos" ALTER COLUMN "estado" TYPE "public"."bovinos_estado_enum_old" USING "estado"::"text"::"public"."bovinos_estado_enum_old"`);
        await queryRunner.query(`ALTER TABLE "bovinos" ALTER COLUMN "estado" SET DEFAULT 'activo'`);
        await queryRunner.query(`DROP TYPE "public"."bovinos_estado_enum"`);
        await queryRunner.query(`ALTER TYPE "public"."bovinos_estado_enum_old" RENAME TO "bovinos_estado_enum"`);
        await queryRunner.query(`CREATE TYPE "public"."bovinos_etapa_productiva_enum_old" AS ENUM('produccion', 'crecimiento', 'seca', 'sin_clasificar')`);
        await queryRunner.query(`ALTER TABLE "bovinos" ALTER COLUMN "etapa_productiva" DROP DEFAULT`);
        await queryRunner.query(`ALTER TABLE "bovinos" ALTER COLUMN "etapa_productiva" TYPE "public"."bovinos_etapa_productiva_enum_old" USING "etapa_productiva"::"text"::"public"."bovinos_etapa_productiva_enum_old"`);
        await queryRunner.query(`ALTER TABLE "bovinos" ALTER COLUMN "etapa_productiva" SET DEFAULT 'sin_clasificar'`);
        await queryRunner.query(`DROP TYPE "public"."bovinos_etapa_productiva_enum"`);
        await queryRunner.query(`ALTER TYPE "public"."bovinos_etapa_productiva_enum_old" RENAME TO "bovinos_etapa_productiva_enum"`);
    }

}
