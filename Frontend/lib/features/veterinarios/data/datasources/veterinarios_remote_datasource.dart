import 'package:dio/dio.dart';
import '../../domain/entities/veterinario.dart';

class VeterinariosRemoteDataSource {
  final Dio _dio;
  VeterinariosRemoteDataSource(this._dio);

  Future<List<Veterinario>> getAll() async {
    final response = await _dio.get('/veterinarios');
    return (response.data as List).map((e) => Veterinario.fromJson(e)).toList();
  }

  Future<Veterinario> getOne(int id) async {
    final response = await _dio.get('/veterinarios/$id');
    return Veterinario.fromJson(response.data);
  }

  Future<Veterinario> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/veterinarios', data: data);
    return Veterinario.fromJson(response.data);
  }

  Future<Veterinario> update(int id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/veterinarios/$id', data: data);
    return Veterinario.fromJson(response.data);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/veterinarios/$id');
  }
}
