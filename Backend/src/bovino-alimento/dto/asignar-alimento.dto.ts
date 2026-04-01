import { IsNumber, IsString, IsDateString, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class AsignarAlimentoDto {
  @ApiProperty({ example: 1, description: 'ID del animal' })
  @IsNumber()
  @Type(() => Number)
  animalId: number;

  @ApiProperty({ example: 'ALI001', description: 'ID del alimento' })
  @IsString()
  alimentoId: string;

  @ApiProperty({ example: 5.5, minimum: 0, description: 'Cantidad en kg' })
  @IsNumber()
  @Min(0)
  @Type(() => Number)
  cantidad: number;

  @ApiProperty({ example: '2024-06-15' })
  @IsDateString()
  fecha: string;
}
