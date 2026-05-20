import { IsString, IsOptional, IsNumber } from 'class-validator';

export class CreateProveedorDto {
  @IsString()
  nombre!: string;

  @IsOptional()
  @IsString()
  contacto?: string;

  @IsOptional()
  @IsString()
  telefono?: string;

  @IsOptional()
  @IsString()
  email?: string;

  @IsOptional()
  @IsString()
  direccion?: string;

  @IsOptional()
  @IsString()
  notas?: string;
}

export class CreatePrecioDto {
  @IsString()
  fk_id_alimento!: string;

  @IsNumber()
  precio!: number;

  @IsOptional()
  @IsString()
  unidad?: string;
}