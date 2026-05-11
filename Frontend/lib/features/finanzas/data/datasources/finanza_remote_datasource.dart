import 'package:dio/dio.dart';

import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/finanza.dart';
import '../../domain/repositories/finanza_repository.dart';
import '../models/finanza_model.dart';

class FinanzaRemoteDataSource {
  final Dio _dio;
  FinanzaRemoteDataSource(this._dio);

  Future<PaginatedResponse<FinanzaModel>> list({
    int page = 1,
    int limit = 20,
    TipoMovimiento? tipo,
    String? categoria,
    String? fincaId,
  }) async {
    final response = await _dio.get(
      '/finanzas',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (tipo != null) 'tipo_movimiento': tipo.apiValue,
        if (categoria != null && categoria.isNotEmpty) 'categoria': categoria,
        if (fincaId != null && fincaId.isNotEmpty) 'fincaId': fincaId,
      },
    );
    return PaginatedResponse<FinanzaModel>.fromJson(
      response.data as Map<String, dynamic>,
      FinanzaModel.fromJson,
    );
  }

  Future<FinanzaModel> getById(String id) async {
    final response = await _dio.get('/finanzas/$id');
    return FinanzaModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<FinanzaResumenModel> getResumen({String? fincaId}) async {
    final response = await _dio.get(
      '/finanzas/resumen',
      queryParameters: {
        if (fincaId != null && fincaId.isNotEmpty) 'fincaId': fincaId,
      },
    );
    return FinanzaResumenModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<FinanzaModel> create(CreateFinanzaInput input) async {
    final response = await _dio.post('/finanzas', data: {
      'pk_id_finanza': input.id,
      'tipo_movimiento': input.tipoMovimiento.apiValue,
      'concepto': input.concepto,
      'monto': input.monto,
      if (input.categoria != null) 'categoria': input.categoria,
      if (input.fecha != null)
        'fecha': input.fecha!.toIso8601String().substring(0, 10),
      if (input.factura != null) 'factura': input.factura,
      if (input.metodoPago != null) 'metodo_pago': input.metodoPago,
      if (input.fincaId != null) 'fincaId': input.fincaId,
      if (input.animalId != null) 'animalId': input.animalId,
    });
    return FinanzaModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<FinanzaModel> update(String id, UpdateFinanzaInput input) async {
    final response = await _dio.patch('/finanzas/$id', data: {
      if (input.tipoMovimiento != null)
        'tipo_movimiento': input.tipoMovimiento!.apiValue,
      if (input.concepto != null) 'concepto': input.concepto,
      if (input.categoria != null) 'categoria': input.categoria,
      if (input.monto != null) 'monto': input.monto,
      if (input.fecha != null)
        'fecha': input.fecha!.toIso8601String().substring(0, 10),
      if (input.factura != null) 'factura': input.factura,
      if (input.metodoPago != null) 'metodo_pago': input.metodoPago,
    });
    return FinanzaModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete('/finanzas/$id');
  }
}
