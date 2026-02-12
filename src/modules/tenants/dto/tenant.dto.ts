import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsString, IsOptional, IsBoolean } from 'class-validator';

export class CreateTenantDto {
  @ApiProperty({
    example: 'FarmLink Co.',
    description: 'Tenant name',
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({
    example: 'info@farmlink.com',
    description: 'Tenant email address',
  })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiProperty({
    example: '+1234567890',
    description: 'Tenant phone number',
    required: false,
  })
  @IsString()
  @IsOptional()
  phone?: string;

  @ApiProperty({
    example: '123 Farm Street, Agriculture City, AG 12345',
    description: 'Tenant address',
    required: false,
  })
  @IsString()
  @IsOptional()
  address?: string;
}

export class UpdateTenantDto {
  @ApiProperty({
    example: 'FarmLink Co.',
    description: 'Tenant name',
    required: false,
  })
  @IsString()
  @IsOptional()
  name?: string;

  @ApiProperty({
    example: 'info@farmlink.com',
    description: 'Tenant email address',
    required: false,
  })
  @IsEmail()
  @IsOptional()
  email?: string;

  @ApiProperty({
    example: '+1234567890',
    description: 'Tenant phone number',
    required: false,
  })
  @IsString()
  @IsOptional()
  phone?: string;

  @ApiProperty({
    example: '123 Farm Street, Agriculture City, AG 12345',
    description: 'Tenant address',
    required: false,
  })
  @IsString()
  @IsOptional()
  address?: string;

  @ApiProperty({
    example: true,
    description: 'Tenant active status',
    required: false,
  })
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;
}
