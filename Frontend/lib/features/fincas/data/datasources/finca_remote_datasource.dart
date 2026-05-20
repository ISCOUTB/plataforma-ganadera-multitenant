import 'package:dio/dio.dart';

import '../../../../core/models/paginated_response.dart';
import '../../../animales/data/models/animal_model.dart';
import '../../../potreros/data/models/potrero_model.dart';
import '../../domain/repositories/finca_repository.dart';
import '../models/finca_model.dart';

/// Datasource HTTP de Fincas. NO añade tenant_id — viaja en el JWT.
class FincaRemoteDataSource {
  final Dio _dio;
  FincaRemoteDataSource(this._dio);

  Future<PaginatedResponse<FincaModel>> list({
    int page = 1,
    int limit = 20,
    String? nombre,
    String? ubicacion,
  }) async {
    final response = await _dio.get(
      '/fincas',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (nombre != null && nombre.isNotEmpty) 'nombre_finca': nombre,
        if (ubicacion != null && ubicacion.isNotEmpty) 'ubicacion': ubicacion,
      },
    );
    return PaginatedResponse<FincaModel>.fromJson(
      response.data as Map<String, dynamic>,
      FincaModel.fromJson,
    );
  }

  Future<FincaModel> getById(String id) async {
    final response = await _dio.get('/fincas/$id');
    return FincaModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<FincaModel> create(CreateFincaInput input) async {
    final response = await _dio.post(
      '/fincas',
      data: {
        'pk_id_finca': input.id,
        'nombre_finca': input.nombre,
        if (input.ubicacion != null) 'ubicacion': input.ubicacion,
        if (input.propietario != null) 'propietario': input.propietario,
        if (input.areaTotal != null) 'area_total': input.areaTotal,
        if (input.fechaRegistro != null)
          'fecha_registro':
              input.fechaRegistro!.toIso8601String().substring(0, 10),
      },
    );
    return FincaModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<FincaModel> update(String id, UpdateFincaInput input) async {
    final response = await _dio.patch(
      '/fincas/$id',
      data: {
        if (input.nombre != null) 'nombre_finca': input.nombre,
        if (input.ubicacion != null) 'ubicacion': input.ubicacion,
        if (input.propietario != null) 'propietario': input.propietario,
        if (input.areaTotal != null) 'area_total': input.areaTotal,
        if (input.fechaRegistro != null)
          'fecha_registro':
              input.fechaRegistro!.toIso8601String().substring(0, 10),
      },
    );
    return FincaModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete('/fincas/$id');
  }

  /// GET /fincas/:id/animales — animales activos de la finca.
  Future<List<AnimalModel>> getAnimales(String fincaId) async {
    final response = await _dio.get('/fincas/$fincaId/animales');
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => AnimalModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }

  /// GET /fincas/:id/potreros — potreros de la finca.
  Future<List<PotreroModel>> getPotreros(String fincaId) async {
    final response = await _dio.get('/fincas/$fincaId/potreros');
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => PotreroModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }
}
