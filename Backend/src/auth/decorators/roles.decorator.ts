import { SetMetadata } from '@nestjs/common';
import { Rol } from '../../usuarios/entities/usuario.entity';

// Clave de metadata para el decorador @Roles() — leída por RolesGuard.
export const ROLES_KEY = 'roles';

// @Roles('admin', 'propietario') — restringe la ruta a los roles especificados.
// Si no se coloca este decorador, RolesGuard deja pasar a cualquier usuario autenticado.
// Uso: @Roles(Rol.ADMIN) encima de @Get(), @Post(), etc.
export const Roles = (...roles: Rol[]) => SetMetadata(ROLES_KEY, roles);
