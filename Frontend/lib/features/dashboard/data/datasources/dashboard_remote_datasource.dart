import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/dashboard_inteligencia_model.dart';
import '../models/dashboard_summary_model.dart';

class DashboardRemoteDataSource {
  final Dio _dio;
  DashboardRemoteDataSource(this._dio);

  /// Llama al BFF `GET /api/dashboard/summary`. Si `fincaId` es null se
  /// devuelve la vista global del tenant; en caso contrario el backend
  /// valida ownership y filtra los KPIs a esa finca.
  Future<DashboardSummaryModel> getSummary({String? fincaId}) async {
    final response = await _dio.get(
      ApiEndpoints.dashboardSummary,
      queryParameters: {
        if (fincaId != null) 'fincaId': fincaId,
      },
    );
    return DashboardSummaryModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Llama a `GET /api/dashboard/inteligencia`. Endpoint costoso (5 queries
  /// de agregación), por eso se invoca lazy desde la sección "Inteligencia"
  /// y nunca en el load inicial del dashboard.
  Future<DashboardInteligenciaModel> getInteligencia({String? fincaId}) async {
    final response = await _dio.get(
      ApiEndpoints.dashboardInteligencia,
      queryParameters: {
        if (fincaId != null) 'fincaId': fincaId,
      },
    );
    return DashboardInteligenciaModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
