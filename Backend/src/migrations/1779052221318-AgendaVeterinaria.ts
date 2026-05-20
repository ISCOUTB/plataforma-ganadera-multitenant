import { MigrationInterface, QueryRunner } from "typeorm";

export class AgendaVeterinaria1779052221318 implements MigrationInterface {

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`
            CREATE TABLE "veterinarios" (
                "id" SERIAL NOT NULL,
                "nombre" character varying(150) NOT NULL,
                "especialidad" character varying(100),
                "telefono" character varying(20),
                "email" character varying(150),
                "notas" text,
                "tenant_id" character varying,
                "deleted_at" TIMESTAMP,
                "creado_en" TIMESTAMP NOT NULL DEFAULT now(),
                "updated_at" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "PK_veterinarios" PRIMARY KEY ("id")
            )
        `);

        await queryRunner.query(`
            CREATE TYPE "public"."citas_tipo_enum" AS ENUM(
                'revision_general','vacunacion','desparasitacion',
                'parto_asistido','emergencia','otro'
            )
        `);
        await queryRunner.query(`
            CREATE TYPE "public"."citas_estado_enum" AS ENUM(
                'pendiente','completada','cancelada'
            )
        `);
        await queryRunner.query(`
            CREATE TYPE "public"."citas_alcance_enum" AS ENUM(
                'animal','potrero'
            )
        `);

        await queryRunner.query(`
            CREATE TABLE "citas" (
                "id" SERIAL NOT NULL,
                "tipo" "public"."citas_tipo_enum" NOT NULL,
                "estado" "public"."citas_estado_enum" NOT NULL DEFAULT 'pendiente',
                "alcance" "public"."citas_alcance_enum" NOT NULL,
                "fecha_hora" TIMESTAMP NOT NULL,
                "fk_id_bovino" integer,
                "fk_id_potrero" character varying(15),
                "notas" text,
                "recordatorio_dias" integer,
                "fk_id_veterinario" integer,
                "tenant_id" character varying,
                "deleted_at" TIMESTAMP,
                "creado_en" TIMESTAMP NOT NULL DEFAULT now(),
                "updated_at" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "PK_citas" PRIMARY KEY ("id"),
                CONSTRAINT "FK_citas_veterinario" FOREIGN KEY ("fk_id_veterinario")
                    REFERENCES "veterinarios"("id") ON DELETE NO ACTION
            )
        `);

        await queryRunner.query(`
            CREATE TYPE "public"."tratamientos_estado_enum" AS ENUM(
                'en_curso','completado','abandonado'
            )
        `);

        await queryRunner.query(`
            CREATE TABLE "tratamientos" (
                "id" SERIAL NOT NULL,
                "fk_id_bovino" integer NOT NULL,
                "diagnostico" character varying(255) NOT NULL,
                "fecha_inicio" date NOT NULL,
                "fecha_fin_estimada" date,
                "estado" "public"."tratamientos_estado_enum" NOT NULL DEFAULT 'en_curso',
                "fk_id_veterinario" integer,
                "tenant_id" character varying,
                "deleted_at" TIMESTAMP,
                "creado_en" TIMESTAMP NOT NULL DEFAULT now(),
                "updated_at" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "PK_tratamientos" PRIMARY KEY ("id"),
                CONSTRAINT "FK_tratamientos_veterinario" FOREIGN KEY ("fk_id_veterinario")
                    REFERENCES "veterinarios"("id") ON DELETE NO ACTION
            )
        `);

        await queryRunner.query(`
            CREATE TABLE "seguimientos_tratamiento" (
                "id" SERIAL NOT NULL,
                "fk_id_tratamiento" integer NOT NULL,
                "observacion" text NOT NULL,
                "registrado_por" character varying(150),
                "creado_en" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "PK_seguimientos" PRIMARY KEY ("id"),
                CONSTRAINT "FK_seguimientos_tratamiento" FOREIGN KEY ("fk_id_tratamiento")
                    REFERENCES "tratamientos"("id") ON DELETE CASCADE
            )
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP TABLE "seguimientos_tratamiento"`);
        await queryRunner.query(`DROP TABLE "tratamientos"`);
        await queryRunner.query(`DROP TYPE "public"."tratamientos_estado_enum"`);
        await queryRunner.query(`DROP TABLE "citas"`);
        await queryRunner.query(`DROP TYPE "public"."citas_alcance_enum"`);
        await queryRunner.query(`DROP TYPE "public"."citas_estado_enum"`);
        await queryRunner.query(`DROP TYPE "public"."citas_tipo_enum"`);
        await queryRunner.query(`DROP TABLE "veterinarios"`);
    }
}