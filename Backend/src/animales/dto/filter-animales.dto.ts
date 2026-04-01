import { IsOptional, IsString, IsIn } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { PaginationDto } from '../../common/dto/pagination.dto';

const SORTABLE_COLUMNS = [
  'id', 'numero_identificacion', 'fecha_nacimiento', 'genero',
  'peso', 'raza', 'created_at', 'updated_at',
] as const;

export class FilterAnimalesDto extends PaginationDto {
  @ApiPropertyOptional({
    example: 'created_at',
    enum: SORTABLE_COLUMNS,
    description: 'Campo por el cual ordenar',
  })
  @IsOptional()
  @IsIn(SORTABLE_COLUMNS)
  sortBy?: string;

  @ApiPropertyOptional({ example: 'Brahman', description: 'Filtrar por raza exacta' })
  @IsOptional()
  @IsString()
  raza?: string;

  @ApiPropertyOptional({
    example: 'h',
    enum: ['m', 'h', 'n'],
    description: 'Filtrar por género: m=macho, h=hembra, n=no definido',
  })
  @IsOptional()
  @IsIn(['m', 'h', 'n'])
  genero?: string;

  @ApiPropertyOptional({
    example: 'activo',
    enum: ['activo', 'vendido'],
    description: 'Filtrar por estado: activo o vendido',
  })
  @IsOptional()
  @IsIn(['activo', 'vendido'])
  estado?: string;
}
