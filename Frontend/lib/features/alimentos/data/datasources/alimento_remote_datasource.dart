import 'package:dio/dio.dart';

import '../../../../core/models/paginated_response.dart';
import '../../domain/repositories/alimento_repository.dart';
import '../models/alimento_model.dart';

class AlimentoRemoteDataSource {
  final Dio _dio;
  AlimentoRemoteDataSource(this._dio);

  Future<PaginatedResponse<AlimentoModel>> list({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/alimentos',
      queryParameters: {'page': page, 'limit': limit},
    );
    return PaginatedResponse<AlimentoModel>.fromJson(
      response.data as Map<String, dynamic>,
      AlimentoModel.fromJson,
    );
  }

  Future<AlimentoModel> getById(String id) async {
    final response = await _dio.get('/alimentos/$id');
    return AlimentoModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AlimentoModel> create(CreateAlimentoInput input) async {
    final response = await _dio.post('/alimentos', data: {
      'pk_id_alimento': input.id,
      'tipo_alimento': input.tipoAlimento,
      if (input.cantidadTotal != null) 'cantidad_total': input.cantidadTotal,
      if (input.frecuencia != null) 'frecuencia': input.frecuencia,
      if (input.fechaInicio != null)
        'fecha_inicio':
            input.fechaInicio!.toIso8601String().substring(0, 10),
      if (input.fechaFinEstimada != null)
        'fecha_fin_estimada':
            input.fechaFinEstimada!.toIso8601String().substring(0, 10),
      if (input.costo != null) 'costo': input.costo,
    });
    return AlimentoModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AlimentoModel> update(String id, UpdateAlimentoInput input) async {
    final response = await _dio.patch('/alimentos/$id', data: {
      if (input.tipoAlimento != null) 'tipo_alimento': input.tipoAlimento,
      if (input.cantidadTotal != null) 'cantidad_total': input.cantidadTotal,
      if (input.frecuencia != null) 'frecuencia': input.frecuencia,
      if (input.costo != null) 'costo': input.costo,
    });
    return AlimentoModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete('/alimentos/$id');
  }
}
