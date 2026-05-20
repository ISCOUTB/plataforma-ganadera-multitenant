import { PartialType, OmitType } from '@nestjs/mapped-types';
import { CreateAlimentoDto } from './create-alimento.dto';

export class UpdateAlimentoDto extends PartialType(
  OmitType(CreateAlimentoDto, ['pk_id_alimento'] as const),
) {}
