import { Controller, Get, Post, Patch, Delete, Param, Body, ParseIntPipe, Query } from '@nestjs/common';
import { ProveedoresService } from './proveedores.service';
import { CreateProveedorDto, CreatePrecioDto } from './dto/create-proveedor.dto';
import { UpdateProveedorDto } from './dto/update-proveedor.dto';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('proveedores')
@Controller('proveedores')
export class ProveedoresController {
  constructor(private readonly service: ProveedoresService) {}

  @Get()
  findAll(@CurrentUser() user: any) {
    return this.service.findAll(user.tenantId);
  }

  @Get('comparador')
  getComparador(@Query('alimento') alimento: string, @CurrentUser() user: any) {
    return this.service.getComparador(alimento, user.tenant_id);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number, @CurrentUser() user: any) {
    return this.service.findOne(id, user.tenantId);
  }

  @Post()
  create(@Body() dto: CreateProveedorDto, @CurrentUser() user: any) {
    return this.service.create(dto, user.tenantId);
  }

  @Patch(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateProveedorDto, @CurrentUser() user: any) {
    return this.service.update(id, dto, user.tenantId);
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @CurrentUser() user: any) {
    return this.service.remove(id, user.tenantId);
  }

  @Post(':id/precios')
  addPrecio(@Param('id', ParseIntPipe) id: number, @Body() dto: CreatePrecioDto, @CurrentUser() user: any) {
    return this.service.addPrecio(id, dto, user.tenantId);
  }

  @Delete('precios/:precioId')
  removePrecio(@Param('precioId', ParseIntPipe) precioId: number) {
    return this.service.removePrecio(precioId);
  }
}