import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

// JwtAuthGuard extiende el guard de Passport para la estrategia 'jwt'.
// Uso: @UseGuards(JwtAuthGuard) en cualquier controller o ruta.
// Si el token falta o es inválido, devuelve 401 automáticamente.
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {}
