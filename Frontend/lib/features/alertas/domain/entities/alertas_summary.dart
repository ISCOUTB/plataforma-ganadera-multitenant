import 'package:equatable/equatable.dart';

enum AlertaSeverity { high, medium, low }

extension AlertaSeverityX on AlertaSeverity {
  static AlertaSeverity fromApi(String? raw) => switch (raw) {
        'HIGH' || 'high' => AlertaSeverity.high,
        'LOW' || 'low' => AlertaSeverity.low,
        _ => AlertaSeverity.medium,
      };

  String get label => switch (this) {
        AlertaSeverity.high => 'Alta',
        AlertaSeverity.medium => 'Media',
        AlertaSeverity.low => 'Baja',
      };
}

class AlertaPrioritaria extends Equatable {
  final String tipo;
  final AlertaSeverity severity;
  final Map<String, dynamic> detalle;

  const AlertaPrioritaria({
    required this.tipo,
    required this.severity,
    required this.detalle,
  });

  @override
  List<Object?> get props => [tipo, severity, detalle];
}

class AlertasSummary extends Equatable {
  final int saludProximas;
  final int saludVencidas;
  final int partosProximos;
  final int partosVencidos;
  final int enCelo;
  final int totalAlertas;
  final int urgentes;
  final Map<AlertaSeverity, int> porSeveridad;
  final List<AlertaPrioritaria> alertasPriorizadas;

  const AlertasSummary({
    required this.saludProximas,
    required this.saludVencidas,
    required this.partosProximos,
    required this.partosVencidos,
    required this.enCelo,
    required this.totalAlertas,
    required this.urgentes,
    required this.porSeveridad,
    required this.alertasPriorizadas,
  });

  @override
  List<Object?> get props => [
        saludProximas,
        saludVencidas,
        partosProximos,
        partosVencidos,
        enCelo,
        totalAlertas,
        urgentes,
      ];
}
