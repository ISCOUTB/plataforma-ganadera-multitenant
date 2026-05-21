import { MigrationInterface, QueryRunner } from "typeorm";

export class Proveedores1779220000000 implements MigrationInterface {

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`
            CREATE TABLE "proveedores" (
                "id" SERIAL NOT NULL,
                "nombre" character varying(150) NOT NULL,
                "contacto" character varying(150),
                "telefono" character varying(20),
                "email" character varying(150),
                "direccion" character varying(255),
                "notas" text,
                "tenant_id" character varying,
                "deleted_at" TIMESTAMP,
                "creado_en" TIMESTAMP NOT NULL DEFAULT now(),
                "updated_at" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "PK_proveedores" PRIMARY KEY ("id")
            )
        `);

        await queryRunner.query(`
            CREATE TABLE "proveedor_precios" (
                "id" SERIAL NOT NULL,
                "fk_id_proveedor" integer NOT NULL,
                "fk_id_alimento" character varying(15) NOT NULL,
                "precio" decimal(10,2) NOT NULL,
                "unidad" character varying(50),
                "actualizado_en" TIMESTAMP NOT NULL DEFAULT now(),
                "creado_en" TIMESTAMP NOT NULL DEFAULT now(),
                CONSTRAINT "PK_proveedor_precios" PRIMARY KEY ("id"),
                CONSTRAINT "FK_precio_proveedor" FOREIGN KEY ("fk_id_proveedor")
                    REFERENCES "proveedores"("id") ON DELETE CASCADE,
                CONSTRAINT "FK_precio_alimento" FOREIGN KEY ("fk_id_alimento")
                    REFERENCES "alimento"("pk_id_alimento") ON DELETE CASCADE
            )
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP TABLE "proveedor_precios"`);
        await queryRunner.query(`DROP TABLE "proveedores"`);
    }
}