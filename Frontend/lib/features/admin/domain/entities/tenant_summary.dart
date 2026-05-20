import 'package:equatable/equatable.dart';

class TenantSummary extends Equatable {
  final String tenantId;
  final int userCount;

  const TenantSummary({
    required this.tenantId,
    required this.userCount,
  });

  @override
  List<Object?> get props => [tenantId, userCount];
}
