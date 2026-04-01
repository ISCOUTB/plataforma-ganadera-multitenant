import { IsOptional, IsString, IsIn } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { PaginationDto } from '../../common/dto/pagination.dto';

const SORTABLE_COLUMNS = [
  'id', 'fecha', 'motivo', 'created_at', 'updated_at',
] as const;

export class FilterMovimientosDto extends PaginationDto {
  @ApiPropertyOptional({
    example: 'fecha',
    enum: SORTABLE_COLUMNS,
    description: 'Campo por el cual ordenar',
  })
  @IsOptional()
  @IsIn(SORTABLE_COLUMNS)
  sortBy?: string;

  @ApiPropertyOptional({ example: 'rotación', description: 'Filtrar por motivo exacto' })
  @IsOptional()
  @IsString()
  motivo?: string;
}
