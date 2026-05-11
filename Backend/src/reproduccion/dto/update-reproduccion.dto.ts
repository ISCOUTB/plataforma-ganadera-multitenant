import { PartialType, OmitType } from '@nestjs/mapped-types';
import { CreateReproduccionDto } from './create-reproduccion.dto';

export class UpdateReproduccionDto extends PartialType(
  OmitType(CreateReproduccionDto, ['pk_id_reproduccion'] as const),
) {}
