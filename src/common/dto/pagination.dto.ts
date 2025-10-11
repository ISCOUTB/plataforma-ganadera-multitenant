import { Type } from 'class-transformer';
import { IsOptional, IsPositive, Min } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class PaginationDto {
  @ApiPropertyOptional({ default: 10, minimum: 1 })
  @IsOptional()
  @IsPositive()
  @Type(() => Number)
  limit?: number = 10;

  @ApiPropertyOptional({ default: 0, minimum: 0 })
  @IsOptional()
  @Min(0)
  @Type(() => Number)
  offset?: number = 0;
}