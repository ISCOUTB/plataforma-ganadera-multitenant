import { IsString, IsOptional, IsEmail } from 'class-validator';

export class CreateVeterinarioDto {
  @IsString()
  nombre: string;

  @IsOptional()
  @IsString()
  especialidad?: string;

  @IsOptional()
  @IsString()
  telefono?: string;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsString()
  notas?: string;
}
