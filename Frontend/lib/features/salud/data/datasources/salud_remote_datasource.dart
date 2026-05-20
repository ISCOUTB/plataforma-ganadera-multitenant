import 'package:dio/dio.dart';

import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/salud.dart';
import '../../domain/repositories/salud_repository.dart';
import '../models/salud_model.dart';

class SaludRemoteDataSource {
  final Dio _dio;
  SaludRemoteDataSource(this._dio);

  Future<PaginatedResponse<SaludModel>> list({
    int page = 1,
    int limit = 20,
    TipoIntervencion? tipoIntervencion,
    String? fincaId,
  }) async {
    final response = await _dio.get(
      '/salud',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (tipoIntervencion != null)
          'tipo_intervencion': tipoIntervencion.apiValue,
        if (fincaId != null && fincaId.isNotEmpty) 'fincaId': fincaId,
      },
    );
    return PaginatedResponse<SaludModel>.fromJson(
      response.data as Map<String, dynamic>,
      SaludModel.fromJson,
    );
  }

  Future<SaludModel> getById(int id) async {
    final response = await _dio.get('/salud/$id');
    return SaludModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, List<SaludModel>>> getAlertas() async {
    final response = await _dio.get('/salud/alertas');
    final data = response.data as Map<String, dynamic>;
    return {
      'proximas': ((data['proximas'] as List<dynamic>?) ?? const [])
          .map((e) => SaludModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      'vencidas': ((data['vencidas'] as List<dynamic>?) ?? const [])
          .map((e) => SaludModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    };
  }

  Future<SaludModel> create(CreateSaludInput input) async {
    final response = await _dio.post('/salud', data: {
      'tipo_intervencion': input.tipoIntervencion.apiValue,
      if (input.descripcionEnfermedad != null)
        'descripcion_enfermedad': input.descripcionEnfermedad,
      if (input.productoAplicado != null)
        'producto_aplicado': input.productoAplicado,
      if (input.dosis != null) 'dosis': input.dosis,
      if (input.fechaAplicacion != null)
        'fecha_aplicacion':
            input.fechaAplicacion!.toIso8601String().substring(0, 10),
      if (input.fechaProximaAplicacion != null)
        'fecha_proxima_aplicacion':
            input.fechaProximaAplicacion!.toIso8601String().substring(0, 10),
      if (input.costo != null) 'costo': input.costo,
      if (input.animalId != null) 'animalId': input.animalId,
    });
    return SaludModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SaludModel> update(int id, UpdateSaludInput input) async {
    final response = await _dio.patch('/salud/$id', data: {
      if (input.tipoIntervencion != null)
        'tipo_intervencion': input.tipoIntervencion!.apiValue,
      if (input.productoAplicado != null)
        'producto_aplicado': input.productoAplicado,
      if (input.dosis != null) 'dosis': input.dosis,
      if (input.fechaAplicacion != null)
        'fecha_aplicacion':
            input.fechaAplicacion!.toIso8601String().substring(0, 10),
      if (input.fechaProximaAplicacion != null)
        'fecha_proxima_aplicacion':
            input.fechaProximaAplicacion!.toIso8601String().substring(0, 10),
      if (input.costo != null) 'costo': input.costo,
      if (input.animalId != null) 'animalId': input.animalId,
    });
    return SaludModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/salud/$id');
  }
}
