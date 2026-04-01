import { IsOptional, IsIn } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { PaginationDto } from '../../common/dto/pagination.dto';

const SORTABLE_COLUMNS = [
  'pk_id_reproduccion', 'metodo_reproduccion',
  'fecha_estimado_parto', 'numero_crias', 'creado_en', 'updated_at',
] as const;

export class FilterReproduccionDto extends PaginationDto {
  @ApiPropertyOptional({
    example: 'fecha_estimado_parto',
    enum: SORTABLE_COLUMNS,
    description: 'Campo por el cual ordenar',
  })
  @IsOptional()
  @IsIn(SORTABLE_COLUMNS)
  sortBy?: string;

  @ApiPropertyOptional({
    example: true,
    description: 'Filtrar por estado de preñez',
  })
  @IsOptional()
  @Type(() => Boolean)
  prepiada?: boolean;

  @ApiPropertyOptional({
    example: true,
    description: 'Filtrar por estado de celo',
  })
  @IsOptional()
  @Type(() => Boolean)
  en_celo?: boolean;
}
