import 'package:dio/dio.dart';

import '../../../../core/models/paginated_response.dart';
import '../../../animales/data/models/animal_model.dart';
import '../../domain/repositories/potrero_repository.dart';
import '../models/potrero_model.dart';

class PotreroRemoteDataSource {
  final Dio _dio;
  PotreroRemoteDataSource(this._dio);

  Future<PaginatedResponse<PotreroModel>> list({
    int page = 1,
    int limit = 20,
    String? fincaId,
  }) async {
    final response = await _dio.get(
      '/potreros',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (fincaId != null && fincaId.isNotEmpty) 'fincaId': fincaId,
      },
    );
    return PaginatedResponse<PotreroModel>.fromJson(
      response.data as Map<String, dynamic>,
      PotreroModel.fromJson,
    );
  }

  Future<PotreroModel> getById(String id) async {
    final response = await _dio.get('/potreros/$id');
    return PotreroModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PotreroOcupacionModel> getOcupacion(String id) async {
    final response = await _dio.get('/potreros/$id/ocupacion');
    return PotreroOcupacionModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<PotreroModel> create(CreatePotreroInput input) async {
    final response = await _dio.post(
      '/potreros',
      data: {
        'pk_id_potrero': input.id,
        'nombre_potrero': input.nombre,
        'capacidad_animales': input.capacidadAnimales,
        if (input.area != null) 'area': input.area,
        if (input.estado != null) 'estado': input.estado,
        if (input.fechaRotacion != null)
          'fecha_rotacion':
              input.fechaRotacion!.toIso8601String().substring(0, 10),
        if (input.fechaProximaRotacion != null)
          'fecha_proxima_rotacion':
              input.fechaProximaRotacion!.toIso8601String().substring(0, 10),
        if (input.fincaId != null) 'fincaId': input.fincaId,
      },
    );
    return PotreroModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PotreroModel> update(String id, UpdatePotreroInput input) async {
    final response = await _dio.patch(
      '/potreros/$id',
      data: {
        if (input.nombre != null) 'nombre_potrero': input.nombre,
        if (input.capacidadAnimales != null)
          'capacidad_animales': input.capacidadAnimales,
        if (input.area != null) 'area': input.area,
        if (input.estado != null) 'estado': input.estado,
        if (input.fincaId != null) 'fincaId': input.fincaId,
      },
    );
    return PotreroModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete('/potreros/$id');
  }

  /// GET /potreros/:id/animales — animales activos del potrero.
  Future<List<AnimalModel>> getAnimales(String potreroId) async {
    final response = await _dio.get('/potreros/$potreroId/animales');
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => AnimalModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }
}
