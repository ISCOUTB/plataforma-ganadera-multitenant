import { PartialType, OmitType } from '@nestjs/mapped-types';
import { CreatePotreroDto } from './create-potrero.dto';

// pk_id_potrero no se puede cambiar en update — es la PK del registro.
export class UpdatePotreroDto extends PartialType(
  OmitType(CreatePotreroDto, ['pk_id_potrero'] as const),
) {}
