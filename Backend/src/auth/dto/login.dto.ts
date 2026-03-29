import { IsEmail, IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
  @ApiProperty({ example: 'propietario@farmlink.com', description: 'Correo electrónico del usuario' })
  @IsEmail({}, { message: 'email debe ser un correo válido' })
  email: string;

  @ApiProperty({ example: 'miPassword123', minLength: 6, description: 'Contraseña (mínimo 6 caracteres)' })
  @IsString()
  @MinLength(6, { message: 'password debe tener al menos 6 caracteres' })
  password: string;
}
