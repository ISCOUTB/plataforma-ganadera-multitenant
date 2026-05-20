import { IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

// RefreshTokenDto se usará en Fase 1 completa cuando se implemente
// el flujo de refresh tokens (jwt-refresh.strategy.ts + jwt-refresh.guard.ts).
export class RefreshTokenDto {
  @ApiProperty({ description: 'Refresh token JWT obtenido en login' })
  @IsString()
  refresh_token: string;
}
