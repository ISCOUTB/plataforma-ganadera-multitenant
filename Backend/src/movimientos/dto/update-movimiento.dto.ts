import { IsOptional, IsString, IsDateString, MaxLength } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateMovimientoDto {
  @ApiPropertyOptional({ example: '2024-06-15' })
  @IsOptional()
  @IsDateString()
  fecha?: string;

  @ApiPropertyOptional({
    example: 'POT002',
    description: 'Nuevo potrero destino',
  })
  @IsOptional()
  @IsString()
  potreroDestinoId?: string;

  @ApiPropertyOptional({
    example: 'Corrección: rotación de pastoreo',
    maxLength: 200,
  })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  motivo?: string;
}
