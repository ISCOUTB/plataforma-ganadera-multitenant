import 'package:dio/dio.dart';
import '../../domain/entities/cita.dart';

class CitasRemoteDataSource {
  final Dio _dio;
  CitasRemoteDataSource(this._dio);

  Future<List<Cita>> getAll() async {
    final response = await _dio.get('/citas');
    return (response.data as List).map((e) => Cita.fromJson(e)).toList();
  }

  Future<List<Cita>> getProximas({int dias = 7}) async {
    final response = await _dio.get('/citas/proximas', queryParameters: {'dias': dias});
    return (response.data as List).map((e) => Cita.fromJson(e)).toList();
  }

  Future<Cita> getOne(int id) async {
    final response = await _dio.get('/citas/$id');
    return Cita.fromJson(response.data);
  }

  Future<Cita> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/citas', data: data);
    return Cita.fromJson(response.data);
  }

  Future<Cita> update(int id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/citas/$id', data: data);
    return Cita.fromJson(response.data);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/citas/$id');
  }
}
