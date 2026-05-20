import 'package:equatable/equatable.dart';

class Reproduccion extends Equatable {
  final String id; // pk_id_reproduccion string
  final String? fkIdPadre;
  final String? fkIdMadre;
  final String? metodoReproduccion;
  final bool enCelo;
  final bool prenada;
  final int? numeroCrias;
  final DateTime? fechaEstimadoParto;

  const Reproduccion({
    required this.id,
    required this.enCelo,
    required this.prenada,
    this.fkIdPadre,
    this.fkIdMadre,
    this.metodoReproduccion,
    this.numeroCrias,
    this.fechaEstimadoParto,
  });

  @override
  List<Object?> get props =>
      [id, enCelo, prenada, metodoReproduccion, fechaEstimadoParto];
}

class ReproduccionAlertas extends Equatable {
  final List<Reproduccion> partosProximos;
  final List<Reproduccion> partosVencidos;
  final List<Reproduccion> enCelo;

  const ReproduccionAlertas({
    required this.partosProximos,
    required this.partosVencidos,
    required this.enCelo,
  });

  int get total => partosProximos.length + partosVencidos.length + enCelo.length;

  @override
  List<Object?> get props => [partosProximos, partosVencidos, enCelo];
}
