import { Controller, Post, Get, Body } from '@nestjs/common';
import { UsuariosService } from './usuarios.service';

@Controller('usuarios')
export class UsuariosController {
  constructor(private readonly usuariosService: UsuariosService) {}

  @Post('registro')
  registro(@Body() body: any) {
    return this.usuariosService.registro(body);
  }

  @Post('login')
  login(@Body() body: { email: string; password: string }) {
    return this.usuariosService.login(body.email, body.password);
  }

  @Get()
  findAll() {
    return this.usuariosService.findAll();
  }
}
