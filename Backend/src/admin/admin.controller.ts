import { Controller, Get, Post, Body } from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { Roles } from '../common/decorators/roles.decorator';
import { AdminService } from './admin.service';
import {
  IsEmail,
  IsString,
  MinLength,
  IsOptional,
  IsEnum,
} from 'class-validator';
import { Rol } from '../usuarios/entities/usuario.entity';

class CreateUserDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(6)
  password: string;

  @IsString()
  nombre: string;

  @IsString()
  tenant_id: string;

  @IsOptional()
  @IsEnum(Rol)
  rol?: Rol;

  @IsOptional()
  @IsString()
  telefono?: string;
}

@ApiTags('admin')
@ApiBearerAuth('access-token')
@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  /**
   * Lista todos los tenants del sistema con su conteo de usuarios.
   * Solo accesible con rol `superadmin`.
   */
  @ApiOperation({ summary: 'Listar todos los tenants (superadmin)' })
  @Roles('superadmin')
  @Get('tenants')
  listTenants() {
    return this.adminService.listTenants();
  }

  /**
   * Lista todos los usuarios del sistema cross-tenant.
   * Solo accesible con rol `superadmin`.
   */
  @ApiOperation({ summary: 'Listar todos los usuarios (superadmin)' })
  @Roles('superadmin')
  @Get('users')
  listAllUsers() {
    return this.adminService.listAllUsers();
  }

  /**
   * Crea un usuario en un tenant específico.
   * Solo accesible con rol `superadmin`.
   * Reemplaza el flujo de auto-registro para onboarding controlado.
   */
  @ApiOperation({ summary: 'Crear usuario en un tenant (superadmin)' })
  @Roles('superadmin')
  @Post('create-user')
  createUser(@Body() dto: CreateUserDto) {
    return this.adminService.createUser(dto);
  }
}
