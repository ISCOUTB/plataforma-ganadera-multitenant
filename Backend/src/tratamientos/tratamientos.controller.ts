import { Controller, Get, Post, Patch, Delete, Param, Body, ParseIntPipe } from '@nestjs/common';
import { TratamientosService } from './tratamientos.service';
import { CreateTratamientoDto, CreateSeguimientoDto } from './dto/create-tratamiento.dto';
import { UpdateTratamientoDto } from './dto/update-tratamiento.dto';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('tratamientos')
@Controller('tratamientos')
export class TratamientosController {
  constructor(private readonly service: TratamientosService) {}

  @Get()
  findAll(@CurrentUser() user: any) {
    return this.service.findAll(user.tenantId);
  }

  @Get('animal/:bovinoId')
  findByAnimal(@Param('bovinoId', ParseIntPipe) bovinoId: number, @CurrentUser() user: any) {
    return this.service.findByAnimal(bovinoId, user.tenantId);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number, @CurrentUser() user: any) {
    return this.service.findOne(id, user.tenantId);
  }

  @Post()
  create(@Body() dto: CreateTratamientoDto, @CurrentUser() user: any) {
    return this.service.create(dto, user.tenantId);
  }

  @Patch(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateTratamientoDto, @CurrentUser() user: any) {
    return this.service.update(id, dto, user.tenantId);
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @CurrentUser() user: any) {
    return this.service.remove(id, user.tenantId);
  }

  @Post(':id/seguimientos')
  addSeguimiento(@Param('id', ParseIntPipe) id: number, @Body() dto: CreateSeguimientoDto, @CurrentUser() user: any) {
    return this.service.addSeguimiento(id, dto, user.tenantId);
  }
}
