import { IsOptional, IsString, IsIn } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { PaginationDto } from '../../common/dto/pagination.dto';

const SORTABLE_COLUMNS = [
  'pk_id_potrero', 'nombre_potrero', 'area', 'capacidad_animales',
  'estado', 'fecha_rotacion', 'creado_en', 'updated_at',
] as const;

export class FilterPotrerosDto extends PaginationDto {
  @ApiPropertyOptional({
    example: 'creado_en',
    enum: SORTABLE_COLUMNS,
    description: 'Campo por el cual ordenar',
  })
  @IsOptional()
  @IsIn(SORTABLE_COLUMNS)
  sortBy?: string;

  @ApiPropertyOptional({ example: 'activo', description: 'Filtrar por estado del potrero' })
  @IsOptional()
  @IsString()
  estado?: string;
}
