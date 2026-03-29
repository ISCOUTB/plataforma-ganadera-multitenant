import { SetMetadata } from '@nestjs/common';

// Clave de metadata — debe coincidir con la que lee RolesGuard.
// Exportada para que RolesGuard la importe directamente.
export const ROLES_KEY = 'roles';

// @Roles('admin', 'propietario') — restringe la ruta a los roles indicados.
// Uso: @Roles('admin') antes de un método o controller.
// Compatible con el Rol enum de usuario.entity.ts: usar los valores string
// ('admin', 'propietario', 'empleado') o el enum directamente.
export const Roles = (...roles: string[]) => SetMetadata(ROLES_KEY, roles);
