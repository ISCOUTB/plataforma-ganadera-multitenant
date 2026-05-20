import 'package:dio/dio.dart';

class AlertasRemoteDataSource {
  final Dio _dio;
  AlertasRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> getAll() async {
    final response = await _dio.get('/alertas');
    return response.data as Map<String, dynamic>;
  }
}
