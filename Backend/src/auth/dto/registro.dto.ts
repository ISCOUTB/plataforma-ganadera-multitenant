import { IsEmail, IsString, IsOptional, MinLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class RegistroDto {
  @ApiProperty({ example: 'propietario@farmlink.com' })
  @IsEmail({}, { message: 'email debe ser un correo válido' })
  email: string;

  @ApiProperty({ example: 'miPassword123', minLength: 6 })
  @IsString()
  @MinLength(6, { message: 'password debe tener al menos 6 caracteres' })
  password: string;

  @ApiProperty({ example: 'María García' })
  @IsString()
  nombre: string;

  @ApiPropertyOptional({ example: '+573001234567' })
  @IsOptional()
  @IsString()
  telefono?: string;

  @ApiProperty({ example: 'tenant-a', description: 'ID del tenant (organización)' })
  @IsString({ message: 'tenant_id es obligatorio' })
  tenant_id: string;
}
