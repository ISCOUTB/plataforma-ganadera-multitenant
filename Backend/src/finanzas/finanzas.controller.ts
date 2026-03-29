import { Controller } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('finanzas')
@Controller('finanzas')
export class FinanzasController {}
