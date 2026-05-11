import 'package:dio/dio.dart';

import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/animal.dart';
import '../../domain/repositories/animal_repository.dart';
import '../models/animal_model.dart';

class AnimalRemoteDataSource {
  final Dio _dio;
  AnimalRemoteDataSource(this._dio);

  Future<PaginatedResponse<AnimalModel>> list({
    int page = 1,
    int limit = 20,
    AnimalFilter filter = const AnimalFilter(),
    String? fincaId,
  }) async {
    final response = await _dio.get(
      '/animales',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (filter.raza != null && filter.raza!.isNotEmpty) 'raza': filter.raza,
        if (filter.genero != null) 'genero': filter.genero!.apiValue,
        if (filter.estado != null) 'estado': filter.estado!.apiValue,
        if (fincaId != null && fincaId.isNotEmpty) 'fincaId': fincaId,
      },
    );
    return PaginatedResponse<AnimalModel>.fromJson(
      response.data as Map<String, dynamic>,
      AnimalModel.fromJson,
    );
  }

  Future<AnimalModel> getById(int id) async {
    final response = await _dio.get('/animales/$id');
    return AnimalModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AnimalCostosModel> getCostos(int id) async {
    final response = await _dio.get('/animales/$id/costos');
    return AnimalCostosModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AnimalModel> create(CreateAnimalInput input) async {
    final response = await _dio.post(
      '/animales',
      data: {
        'numero_identificacion': input.numeroIdentificacion,
        'fecha_nacimiento':
            input.fechaNacimiento.toIso8601String().substring(0, 10),
        'genero': input.genero.apiValue,
        'peso': input.peso,
        'raza': input.raza,
        if (input.metodoIdentificacion != null)
          'metodo_identificacion': input.metodoIdentificacion,
        if (input.altura != null) 'altura': input.altura,
        if (input.origen != null) 'origen': input.origen,
        if (input.fechaIngreso != null)
          'fecha_ingreso':
              input.fechaIngreso!.toIso8601String().substring(0, 10),
        if (input.fincaId != null) 'fincaId': input.fincaId,
        if (input.potreroId != null) 'potreroId': input.potreroId,
      },
    );
    return AnimalModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AnimalModel> update(int id, UpdateAnimalInput input) async {
    final response = await _dio.patch(
      '/animales/$id',
      data: {
        if (input.numeroIdentificacion != null)
          'numero_identificacion': input.numeroIdentificacion,
        if (input.fechaNacimiento != null)
          'fecha_nacimiento':
              input.fechaNacimiento!.toIso8601String().substring(0, 10),
        if (input.genero != null) 'genero': input.genero!.apiValue,
        if (input.peso != null) 'peso': input.peso,
        if (input.raza != null) 'raza': input.raza,
        if (input.altura != null) 'altura': input.altura,
        if (input.fincaId != null) 'fincaId': input.fincaId,
        if (input.potreroId != null) 'potreroId': input.potreroId,
      },
    );
    return AnimalModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/animales/$id');
  }

  Future<List<Map<String, dynamic>>> getTimeline(int id) async {
    final response = await _dio.get('/animales/$id/timeline');
    final data = response.data;
    if (data is List) {
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return const [];
  }

  Future<AnimalModel> vender(int id, VenderAnimalInput input) async {
    final response = await _dio.post(
      '/animales/$id/vender',
      data: {
        'precio_venta': input.precioVenta,
        'comprador': input.comprador,
        'fecha_venta': input.fechaVenta.toIso8601String().substring(0, 10),
        if (input.fincaId != null) 'fincaId': input.fincaId,
      },
    );
    // El backend devuelve { animal: {...}, finanza: {...} } — solo nos
    // interesa el animal (el movimiento financiero se crea solo en backend).
    final body = response.data as Map<String, dynamic>;
    final animalJson = (body['animal'] as Map<String, dynamic>?) ?? body;
    return AnimalModel.fromJson(animalJson);
  }
}
