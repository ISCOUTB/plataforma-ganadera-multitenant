import { Controller } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('salud')
@Controller('salud')
export class SaludController {}
