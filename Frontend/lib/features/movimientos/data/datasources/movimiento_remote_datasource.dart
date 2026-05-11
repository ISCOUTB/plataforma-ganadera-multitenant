import 'package:dio/dio.dart';

import '../../../../core/models/paginated_response.dart';
import '../../domain/repositories/movimiento_repository.dart';
import '../models/movimiento_model.dart';

class MovimientoRemoteDataSource {
  final Dio _dio;
  MovimientoRemoteDataSource(this._dio);

  Future<PaginatedResponse<MovimientoModel>> list({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/movimientos',
      queryParameters: {'page': page, 'limit': limit},
    );
    return PaginatedResponse<MovimientoModel>.fromJson(
      response.data as Map<String, dynamic>,
      MovimientoModel.fromJson,
    );
  }

  Future<List<MovimientoModel>> getByAnimal(int animalId) async {
    final response = await _dio.get('/movimientos/animal/$animalId');
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => MovimientoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }

  Future<MovimientoModel> create(CreateMovimientoInput input) async {
    final response = await _dio.post('/movimientos', data: {
      'animalId': input.animalId,
      'potreroOrigenId': input.potreroOrigenId,
      'potreroDestinoId': input.potreroDestinoId,
      'fecha': input.fecha.toIso8601String().substring(0, 10),
      if (input.motivo != null) 'motivo': input.motivo,
    });
    return MovimientoModel.fromJson(response.data as Map<String, dynamic>);
  }
}
