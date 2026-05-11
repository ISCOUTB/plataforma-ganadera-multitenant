import { IsOptional, IsIn } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { PaginationDto } from '../../common/dto/pagination.dto';

const SORTABLE_COLUMNS = [
  'fecha', 'cantidad',
] as const;

export class FilterBovinoAlimentoDto extends PaginationDto {
  @ApiPropertyOptional({
    example: 'fecha',
    enum: SORTABLE_COLUMNS,
    description: 'Campo por el cual ordenar',
  })
  @IsOptional()
  @IsIn(SORTABLE_COLUMNS)
  sortBy?: string;

  @ApiPropertyOptional({ example: 1, description: 'Filtrar por animal ID' })
  @IsOptional()
  @Type(() => Number)
  animalId?: number;
}
