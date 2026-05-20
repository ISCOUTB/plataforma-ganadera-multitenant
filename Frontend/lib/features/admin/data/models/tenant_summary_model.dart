import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/tenant_summary.dart';

class TenantSummaryModel {
  static TenantSummary fromJson(Map<String, dynamic> json) {
    return TenantSummary(
      tenantId: (json['tenant_id'] as String?) ?? '',
      userCount: parseInt(json['user_count']) ?? 0,
    );
  }
}
