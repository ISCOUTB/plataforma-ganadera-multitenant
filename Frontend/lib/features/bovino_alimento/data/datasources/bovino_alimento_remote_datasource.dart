import 'package:dio/dio.dart';

import '../../../../core/models/paginated_response.dart';
import '../models/bovino_alimento_model.dart';

class BovinoAlimentoRemoteDataSource {
  final Dio _dio;
  BovinoAlimentoRemoteDataSource(this._dio);

  /// POST /bovino-alimento — asigna un alimento a un animal.
  Future<BovinoAlimentoModel> assign({
    required int animalId,
    required String alimentoId,
    required double cantidad,
    required DateTime fecha,
  }) async {
    final response = await _dio.post('/bovino-alimento', data: {
      'animalId': animalId,
      'alimentoId': alimentoId,
      'cantidad': cantidad,
      'fecha': fecha.toIso8601String().substring(0, 10),
    });
    return BovinoAlimentoModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /bovino-alimento — lista paginada global.
  Future<PaginatedResponse<BovinoAlimentoModel>> list({
    int page = 1,
    int limit = 20,
    int? animalId,
  }) async {
    final response = await _dio.get('/bovino-alimento', queryParameters: {
      'page': page,
      'limit': limit,
      if (animalId != null) 'animalId': animalId,
    });
    return PaginatedResponse<BovinoAlimentoModel>.fromJson(
      response.data as Map<String, dynamic>,
      BovinoAlimentoModel.fromJson,
    );
  }

  /// GET /bovino-alimento/animal/:animalId — historial de un animal con alimento cargado.
  Future<List<BovinoAlimentoModel>> getByAnimal(int animalId) async {
    final response = await _dio.get('/bovino-alimento/animal/$animalId');
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => BovinoAlimentoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }

  /// DELETE /bovino-alimento/:animalId/:alimentoId — elimina una asignación.
  Future<void> remove(int animalId, String alimentoId) async {
    await _dio.delete('/bovino-alimento/$animalId/$alimentoId');
  }
}
