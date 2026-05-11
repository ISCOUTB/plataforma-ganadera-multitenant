import { MigrationInterface, QueryRunner } from "typeorm";

export class InitialSchema1777518257385 implements MigrationInterface {
    name = 'InitialSchema1777518257385'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "usuarios" ("id" SERIAL NOT NULL, "email" character varying NOT NULL, "password" character varying NOT NULL, "nombre" character varying NOT NULL, "telefono" character varying, "rol" character varying(20) NOT NULL DEFAULT 'admin', "tenant_id" character varying, "refresh_token_hash" character varying, "deleted_at" TIMESTAMP, "created_by" integer, "updated_by" integer, "creado_en" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "UQ_446adfc18b35418aac32ae0b7b5" UNIQUE ("email"), CONSTRAINT "PK_d7281c63c176e152e4c531594a8" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TABLE "potreros" ("pk_id_potrero" character varying(15) NOT NULL, "nombre_potrero" character varying(100) NOT NULL, "area" numeric, "capacidad_animales" integer NOT NULL, "estado" character varying(30), "fecha_rotacion" date, "fecha_proxima_rotacion" date, "tenant_id" character varying, "deleted_at" TIMESTAMP, "created_by" integer, "updated_by" integer, "creado_en" TIMESTAMP NOT NULL DEFAULT now(), "updated_at" TIMESTAMP NOT NULL DEFAULT now(), "fk_id_finca" character varying(15), CONSTRAINT "PK_ee82ef8d7e831aa7fcf857301c6" PRIMARY KEY ("pk_id_potrero"))`);
        await queryRunner.query(`CREATE TYPE "public"."bovinos_genero_enum" AS ENUM('m', 'h', 'n')`);
        await queryRunner.query(`CREATE TYPE "public"."bovinos_etapa_productiva_enum" AS ENUM('produccion', 'crecimiento', 'seca', 'sin_clasificar')`);
        await queryRunner.query(`CREATE TYPE "public"."bovinos_estado_enum" AS ENUM('activo', 'vendido')`);
        await queryRunner.query(`CREATE TABLE "bovinos" ("id" SERIAL NOT NULL, "tenant_id" character varying, "created_at" TIMESTAMP NOT NULL DEFAULT now(), "updated_at" TIMESTAMP NOT NULL DEFAULT now(), "deleted_at" TIMESTAMP, "created_by" integer, "updated_by" integer, "numero_identificacion" character varying NOT NULL, "metodo_identificacion" character varying, "fecha_nacimiento" date NOT NULL, "edad_actual" integer, "genero" "public"."bovinos_genero_enum" NOT NULL, "peso" numeric(7,2) NOT NULL, "altura" numeric(5,2), "raza" character varying NOT NULL, "origen" character varying, "fecha_ingreso" date, "fecha_salida" date, "relacion_genealogica" character varying, "etapa_productiva" "public"."bovinos_etapa_productiva_enum" NOT NULL DEFAULT 'sin_clasificar', "estado" "public"."bovinos_estado_enum" NOT NULL DEFAULT 'activo', "precio_venta" numeric(12,2), "comprador" character varying(150), "fincaPkIdFinca" character varying(15), "potreroPkIdPotrero" character varying(15), CONSTRAINT "PK_de3a24cfd1565c672393a77a13b" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TABLE "finca" ("pk_id_finca" character varying(15) NOT NULL, "nombre_finca" character varying(100) NOT NULL, "ubicacion" character varying(150), "propietario" character varying(100), "area_total" numeric, "fecha_registro" date, "tenant_id" character varying, "deleted_at" TIMESTAMP, "created_by" integer, "updated_by" integer, "creado_en" TIMESTAMP NOT NULL DEFAULT now(), "updated_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_b6428be1fd7f09ae324e478d568" PRIMARY KEY ("pk_id_finca"))`);
        await queryRunner.query(`CREATE TABLE "alimento" ("pk_id_alimento" character varying(15) NOT NULL, "tipo_alimento" character varying(100) NOT NULL, "cantidad_total" numeric, "frecuencia" character varying(50), "fecha_inicio" date, "fecha_fin_estimada" date, "costo" numeric, "tenant_id" character varying, "deleted_at" TIMESTAMP, "created_by" integer, "updated_by" integer, "creado_en" TIMESTAMP NOT NULL DEFAULT now(), "updated_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_f2a1ea92211e52bf60ac5618a39" PRIMARY KEY ("pk_id_alimento"))`);
        await queryRunner.query(`CREATE TYPE "public"."salud_tipo_intervencion_enum" AS ENUM('vacunacion', 'vitaminas', 'desparasitacion', 'enfermedad')`);
        await queryRunner.query(`CREATE TABLE "salud" ("id" SERIAL NOT NULL, "tenant_id" character varying, "created_at" TIMESTAMP NOT NULL DEFAULT now(), "updated_at" TIMESTAMP NOT NULL DEFAULT now(), "deleted_at" TIMESTAMP, "created_by" integer, "updated_by" integer, "tipo_intervencion" "public"."salud_tipo_intervencion_enum" NOT NULL, "descripcion_enfermedad" character varying(255), "producto_aplicado" character varying(100), "dosis" character varying(50), "fecha_aplicacion" date, "fecha_proxima_aplicacion" date, "costo" numeric, "fk_id_bovino" integer, CONSTRAINT "PK_e14d9b506929dc09d39f6a94fa8" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE INDEX "idx_salud_tenant_proxima" ON "salud" ("tenant_id", "fecha_proxima_aplicacion") `);
        await queryRunner.query(`CREATE TABLE "reproduccion" ("pk_id_reproduccion" character varying(15) NOT NULL, "fk_id_padre" character varying(15), "fk_id_madre" character varying(15), "metodo_reproduccion" character varying(30), "en_celo" boolean NOT NULL DEFAULT false, "preñada" boolean NOT NULL DEFAULT false, "numero_crias" integer, "fecha_estimado_parto" date, "tenant_id" character varying, "deleted_at" TIMESTAMP, "created_by" integer, "updated_by" integer, "creado_en" TIMESTAMP NOT NULL DEFAULT now(), "updated_at" TIMESTAMP NOT NULL DEFAULT now(), "bovinoId" integer, CONSTRAINT "PK_de5ad524322d5dd3e78ead2cbd0" PRIMARY KEY ("pk_id_reproduccion"))`);
        await queryRunner.query(`CREATE TYPE "public"."finanzas_tipo_movimiento_enum" AS ENUM('ingreso', 'gasto')`);
        await queryRunner.query(`CREATE TABLE "finanzas" ("pk_id_finanza" character varying(15) NOT NULL, "tipo_movimiento" "public"."finanzas_tipo_movimiento_enum" NOT NULL, "concepto" character varying(200), "categoria" character varying(50), "monto" numeric NOT NULL, "fecha" date NOT NULL, "factura" character varying(100), "metodo_pago" character varying(30), "tenant_id" character varying, "deleted_at" TIMESTAMP, "created_by" integer, "updated_by" integer, "creado_en" TIMESTAMP NOT NULL DEFAULT now(), "updated_at" TIMESTAMP NOT NULL DEFAULT now(), "fk_id_finca" character varying(15), "fk_id_bovino" integer, CONSTRAINT "PK_c3d8969d017ec1f2eed50f70ef4" PRIMARY KEY ("pk_id_finanza"))`);
        await queryRunner.query(`CREATE INDEX "idx_finanzas_tenant_fecha" ON "finanzas" ("tenant_id", "fecha") `);
        await queryRunner.query(`CREATE TABLE "bovino_alimento" ("fk_id_bovino" integer NOT NULL, "fk_id_alimento" character varying(15) NOT NULL, "cantidad" numeric NOT NULL, "fecha" date NOT NULL, "tenant_id" character varying, "bovinoId" integer, "alimentoPkIdAlimento" character varying(15), CONSTRAINT "PK_afdb008829152523d874c16cddb" PRIMARY KEY ("fk_id_bovino", "fk_id_alimento"))`);
        await queryRunner.query(`CREATE TABLE "movimientos_animal" ("id" SERIAL NOT NULL, "tenant_id" character varying, "created_at" TIMESTAMP NOT NULL DEFAULT now(), "updated_at" TIMESTAMP NOT NULL DEFAULT now(), "deleted_at" TIMESTAMP, "created_by" integer, "updated_by" integer, "fecha" date NOT NULL, "motivo" character varying(200), "fk_id_bovino" integer, "fk_potrero_origen" character varying(15), "fk_potrero_destino" character varying(15), CONSTRAINT "PK_2ced7363365eebb80bd03a56342" PRIMARY KEY ("id"))`);
        await queryRunner.query(`ALTER TABLE "potreros" ADD CONSTRAINT "FK_26788defa1f44c116b14d65bb8a" FOREIGN KEY ("fk_id_finca") REFERENCES "finca"("pk_id_finca") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "bovinos" ADD CONSTRAINT "FK_de53c570231967f8503dd70e992" FOREIGN KEY ("fincaPkIdFinca") REFERENCES "finca"("pk_id_finca") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "bovinos" ADD CONSTRAINT "FK_b2b04b24f39a15400c969147740" FOREIGN KEY ("potreroPkIdPotrero") REFERENCES "potreros"("pk_id_potrero") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "salud" ADD CONSTRAINT "FK_f48f3e58fc0f6363c85e3b119c0" FOREIGN KEY ("fk_id_bovino") REFERENCES "bovinos"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "reproduccion" ADD CONSTRAINT "FK_9d7be18850ee322d461e3e5bdf8" FOREIGN KEY ("bovinoId") REFERENCES "bovinos"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "finanzas" ADD CONSTRAINT "FK_3ba39c88cb86dca03e82d1ab139" FOREIGN KEY ("fk_id_finca") REFERENCES "finca"("pk_id_finca") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "finanzas" ADD CONSTRAINT "FK_8f42a97bb3d0bf1b8c900a5f3a4" FOREIGN KEY ("fk_id_bovino") REFERENCES "bovinos"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "bovino_alimento" ADD CONSTRAINT "FK_4960430b2a9082328392d2840dd" FOREIGN KEY ("bovinoId") REFERENCES "bovinos"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "bovino_alimento" ADD CONSTRAINT "FK_c3e2f9fd8dc385985b618a643d8" FOREIGN KEY ("alimentoPkIdAlimento") REFERENCES "alimento"("pk_id_alimento") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "movimientos_animal" ADD CONSTRAINT "FK_cdfde5cb1b590bd4514d153ccdb" FOREIGN KEY ("fk_id_bovino") REFERENCES "bovinos"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "movimientos_animal" ADD CONSTRAINT "FK_d1bbc45fc3306ff0494faa2a77a" FOREIGN KEY ("fk_potrero_origen") REFERENCES "potreros"("pk_id_potrero") ON DELETE NO ACTION ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "movimientos_animal" ADD CONSTRAINT "FK_840fa6bcfb229a2e799b9b77485" FOREIGN KEY ("fk_potrero_destino") REFERENCES "potreros"("pk_id_potrero") ON DELETE NO ACTION ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "movimientos_animal" DROP CONSTRAINT "FK_840fa6bcfb229a2e799b9b77485"`);
        await queryRunner.query(`ALTER TABLE "movimientos_animal" DROP CONSTRAINT "FK_d1bbc45fc3306ff0494faa2a77a"`);
        await queryRunner.query(`ALTER TABLE "movimientos_animal" DROP CONSTRAINT "FK_cdfde5cb1b590bd4514d153ccdb"`);
        await queryRunner.query(`ALTER TABLE "bovino_alimento" DROP CONSTRAINT "FK_c3e2f9fd8dc385985b618a643d8"`);
        await queryRunner.query(`ALTER TABLE "bovino_alimento" DROP CONSTRAINT "FK_4960430b2a9082328392d2840dd"`);
        await queryRunner.query(`ALTER TABLE "finanzas" DROP CONSTRAINT "FK_8f42a97bb3d0bf1b8c900a5f3a4"`);
        await queryRunner.query(`ALTER TABLE "finanzas" DROP CONSTRAINT "FK_3ba39c88cb86dca03e82d1ab139"`);
        await queryRunner.query(`ALTER TABLE "reproduccion" DROP CONSTRAINT "FK_9d7be18850ee322d461e3e5bdf8"`);
        await queryRunner.query(`ALTER TABLE "salud" DROP CONSTRAINT "FK_f48f3e58fc0f6363c85e3b119c0"`);
        await queryRunner.query(`ALTER TABLE "bovinos" DROP CONSTRAINT "FK_b2b04b24f39a15400c969147740"`);
        await queryRunner.query(`ALTER TABLE "bovinos" DROP CONSTRAINT "FK_de53c570231967f8503dd70e992"`);
        await queryRunner.query(`ALTER TABLE "potreros" DROP CONSTRAINT "FK_26788defa1f44c116b14d65bb8a"`);
        await queryRunner.query(`DROP TABLE "movimientos_animal"`);
        await queryRunner.query(`DROP TABLE "bovino_alimento"`);
        await queryRunner.query(`DROP INDEX "public"."idx_finanzas_tenant_fecha"`);
        await queryRunner.query(`DROP TABLE "finanzas"`);
        await queryRunner.query(`DROP TYPE "public"."finanzas_tipo_movimiento_enum"`);
        await queryRunner.query(`DROP TABLE "reproduccion"`);
        await queryRunner.query(`DROP INDEX "public"."idx_salud_tenant_proxima"`);
        await queryRunner.query(`DROP TABLE "salud"`);
        await queryRunner.query(`DROP TYPE "public"."salud_tipo_intervencion_enum"`);
        await queryRunner.query(`DROP TABLE "alimento"`);
        await queryRunner.query(`DROP TABLE "finca"`);
        await queryRunner.query(`DROP TABLE "bovinos"`);
        await queryRunner.query(`DROP TYPE "public"."bovinos_estado_enum"`);
        await queryRunner.query(`DROP TYPE "public"."bovinos_etapa_productiva_enum"`);
        await queryRunner.query(`DROP TYPE "public"."bovinos_genero_enum"`);
        await queryRunner.query(`DROP TABLE "potreros"`);
        await queryRunner.query(`DROP TABLE "usuarios"`);
    }

}
