import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';
import { Exclude } from 'class-transformer';
// Usuario — Grupo D: id ya es number auto-gen (compatible con BaseEntity),
// pero tiene campos auth-específicos (@Exclude) que impiden extenderla limpiamente.
// Columnas de auditoría faltantes se agregan inline.

// Enum de roles — tipado fuerte en lugar de string libre.
// 'admin' es el rol de super-usuario; 'propietario' gestiona su finca;
// 'empleado' tiene acceso de solo lectura. Fase 4 aplicará restricciones completas.
export enum Rol {
  ADMIN = 'admin',
  PROPIETARIO = 'propietario',
  EMPLEADO = 'empleado',
}

@Entity('usuarios')
export class Usuario {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  email: string;

  // @Exclude() hace que ClassSerializerInterceptor omita este campo
  // en todas las respuestas HTTP. El valor sigue accesible en memoria
  // para comparaciones internas (bcrypt.compare en auth.service.ts).
  @Exclude()
  @Column()
  password: string;

  @Column()
  nombre: string;

  @Column({ nullable: true })
  telefono: string;

  // type: 'varchar' evita crear un tipo ENUM nativo en PostgreSQL,
  // lo que simplifica las migraciones futuras (Fase 2).
  @Column({ type: 'varchar', length: 20, default: Rol.ADMIN })
  rol: Rol;

  // nullable: true porque en Fase 0–1 el tenant aún no se asigna automáticamente.
  // En Fase 4 (multitenant) este campo tendrá FK a Finca y será obligatorio.
  @Column({ nullable: true })
  tenant_id: string;

  // Hash bcrypt del refresh token activo. null cuando el usuario no tiene sesión.
  // Se actualiza en login/refresh y se limpia en logout.
  @Exclude()
  @Column({ type: 'varchar', nullable: true })
  refresh_token_hash: string | null;

  // Soft delete — BaseRepository.softDelete() pone deleted_at = NOW().
  @Column({ type: 'timestamp', nullable: true, default: null })
  deleted_at: Date | null;

  // Auditoría — quién creó/actualizó el usuario (userId del actor).
  @Column({ type: 'int', nullable: true, default: null })
  created_by: number | null;

  @Column({ type: 'int', nullable: true, default: null })
  updated_by: number | null;

  @CreateDateColumn()
  creado_en: Date;
}
