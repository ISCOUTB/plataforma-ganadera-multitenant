import {
  IsEmail,
  IsEnum,
  IsOptional,
  IsString,
  MinLength,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Rol } from '../entities/usuario.entity';

export class CreateUsuarioDto {
  @ApiProperty({ example: 'juan@finca.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ minLength: 6 })
  @IsString()
  @MinLength(6)
  password: string;

  @ApiProperty()
  @IsString()
  nombre: string;

  @ApiPropertyOptional({ enum: Rol, default: Rol.EMPLEADO })
  @IsOptional()
  @IsEnum(Rol)
  rol?: Rol;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  telefono?: string;
}
