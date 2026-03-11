import { Controller, Get } from '@nestjs/common';
import { AlimentosService } from './alimentos.service';

@Controller('alimentos')  
export class AlimentosController {
  constructor(private readonly alimentosService: AlimentosService) {}

  @Get()  
  findAll() {
    return this.alimentosService.findAll();
  }
}