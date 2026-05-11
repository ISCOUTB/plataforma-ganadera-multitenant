import 'package:dio/dio.dart';

import '../../../../core/models/paginated_response.dart';
import '../../domain/repositories/reproduccion_repository.dart';
import '../models/reproduccion_model.dart';

class ReproduccionRemoteDataSource {
  final Dio _dio;
  ReproduccionRemoteDataSource(this._dio);

  Future<PaginatedResponse<ReproduccionModel>> list({
    int page = 1,
    int limit = 20,
    String? fincaId,
  }) async {
    final response = await _dio.get(
      '/reproduccion',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (fincaId != null && fincaId.isNotEmpty) 'fincaId': fincaId,
      },
    );
    return PaginatedResponse<ReproduccionModel>.fromJson(
      response.data as Map<String, dynamic>,
      ReproduccionModel.fromJson,
    );
  }

  Future<ReproduccionModel> getById(String id) async {
    final response = await _dio.get('/reproduccion/$id');
    return ReproduccionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, List<ReproduccionModel>>> getAlertas() async {
    final response = await _dio.get('/reproduccion/alertas');
    final data = response.data as Map<String, dynamic>;
    List<ReproduccionModel> parse(String key) =>
        ((data[key] as List<dynamic>?) ?? const [])
            .map((e) => ReproduccionModel.fromJson(e as Map<String, dynamic>))
            .toList();
    return {
      'partos_proximos': parse('partos_proximos'),
      'partos_vencidos': parse('partos_vencidos'),
      'en_celo': parse('en_celo'),
    };
  }

  Future<ReproduccionModel> create(CreateReproduccionInput input) async {
    final response = await _dio.post('/reproduccion', data: {
      'pk_id_reproduccion': input.id,
      if (input.fkIdPadre != null) 'fk_id_padre': input.fkIdPadre,
      if (input.fkIdMadre != null) 'fk_id_madre': input.fkIdMadre,
      if (input.metodoReproduccion != null)
        'metodo_reproduccion': input.metodoReproduccion,
      'en_celo': input.enCelo,
      'preñada': input.prenada,
      if (input.numeroCrias != null) 'numero_crias': input.numeroCrias,
      if (input.fechaEstimadoParto != null)
        'fecha_estimado_parto':
            input.fechaEstimadoParto!.toIso8601String().substring(0, 10),
    });
    return ReproduccionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ReproduccionModel> update(
      String id, UpdateReproduccionInput input) async {
    final response = await _dio.patch('/reproduccion/$id', data: {
      if (input.fkIdPadre != null) 'fk_id_padre': input.fkIdPadre,
      if (input.fkIdMadre != null) 'fk_id_madre': input.fkIdMadre,
      if (input.metodoReproduccion != null)
        'metodo_reproduccion': input.metodoReproduccion,
      if (input.enCelo != null) 'en_celo': input.enCelo,
      if (input.prenada != null) 'preñada': input.prenada,
      if (input.numeroCrias != null) 'numero_crias': input.numeroCrias,
      if (input.fechaEstimadoParto != null)
        'fecha_estimado_parto':
            input.fechaEstimadoParto!.toIso8601String().substring(0, 10),
    });
    return ReproduccionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete('/reproduccion/$id');
  }
}
