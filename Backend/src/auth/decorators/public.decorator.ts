import { SetMetadata } from '@nestjs/common';

// Clave de metadata usada para marcar rutas como públicas.
// JwtAuthGuard (o un guard global) debe leer esta clave para saltarse la validación JWT.
// Uso: @Public() encima de un @Get(), @Post(), etc.
export const IS_PUBLIC_KEY = 'isPublic';
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
