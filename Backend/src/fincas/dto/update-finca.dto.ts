import { PartialType, OmitType } from '@nestjs/mapped-types';
import { CreateFincaDto } from './create-finca.dto';

// pk_id_finca no se puede cambiar en update — es la PK del registro.
export class UpdateFincaDto extends PartialType(OmitType(CreateFincaDto, ['pk_id_finca'] as const)) {}
