import { PartialType } from '@nestjs/mapped-types';
import { CreateAnimalDto } from './create-animal.dto';

// Todos los campos de CreateAnimalDto son opcionales en update.
// ValidationPipe + transform:true aplican las mismas validaciones a los campos presentes.
export class UpdateAnimalDto extends PartialType(CreateAnimalDto) {}
