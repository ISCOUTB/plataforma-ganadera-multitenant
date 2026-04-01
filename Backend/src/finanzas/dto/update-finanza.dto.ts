import { PartialType, OmitType } from '@nestjs/mapped-types';
import { CreateFinanzaDto } from './create-finanza.dto';

export class UpdateFinanzaDto extends PartialType(
  OmitType(CreateFinanzaDto, ['pk_id_finanza'] as const),
) {}
