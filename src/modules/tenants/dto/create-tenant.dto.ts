import { IsString, IsNotEmpty, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateTenantDto {
  @ApiProperty({ example: 'Finca El Paraíso' })
  @IsString()
  @IsNotEmpty()
  @MinLength(3)
  name: string;
}