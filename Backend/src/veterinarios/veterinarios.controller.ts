import { Controller, Get, Post, Patch, Delete, Param, Body, ParseIntPipe } from '@nestjs/common';
import { VeterinariosService } from './veterinarios.service';
import { CreateVeterinarioDto } from './dto/create-veterinario.dto';
import { UpdateVeterinarioDto } from './dto/update-veterinario.dto';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('veterinarios')
@Controller('veterinarios')
export class VeterinariosController {
  constructor(private readonly service: VeterinariosService) {}

  @Get()
  findAll(@CurrentUser() user: any) {
    return this.service.findAll(user.tenantId);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number, @CurrentUser() user: any) {
    return this.service.findOne(id, user.tenantId);
  }

  @Post()
  create(@Body() dto: CreateVeterinarioDto, @CurrentUser() user: any) {
    return this.service.create(dto, user.tenantId);
  }

  @Patch(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateVeterinarioDto, @CurrentUser() user: any) {
    return this.service.update(id, dto, user.tenantId);
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @CurrentUser() user: any) {
    return this.service.remove(id, user.tenantId);
  }
}
