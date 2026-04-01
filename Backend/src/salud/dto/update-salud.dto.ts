import { PartialType } from '@nestjs/mapped-types';
import { CreateSaludDto } from './create-salud.dto';

export class UpdateSaludDto extends PartialType(CreateSaludDto) {}
