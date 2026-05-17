import 'package:dio/dio.dart';
import '../../domain/entities/tratamiento.dart';

class TratamientosRemoteDataSource {
  final Dio _dio;
  TratamientosRemoteDataSource(this._dio);

  Future<List<Tratamiento>> getAll() async {
    final response = await _dio.get('/tratamientos');
    return (response.data as List).map((e) => Tratamiento.fromJson(e)).toList();
  }

  Future<List<Tratamiento>> getByAnimal(int bovinoId) async {
    final response = await _dio.get('/tratamientos/animal/$bovinoId');
    return (response.data as List).map((e) => Tratamiento.fromJson(e)).toList();
  }

  Future<Tratamiento> getOne(int id) async {
    final response = await _dio.get('/tratamientos/$id');
    return Tratamiento.fromJson(response.data);
  }

  Future<Tratamiento> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/tratamientos', data: data);
    return Tratamiento.fromJson(response.data);
  }

  Future<Tratamiento> update(int id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/tratamientos/$id', data: data);
    return Tratamiento.fromJson(response.data);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/tratamientos/$id');
  }

  Future<SeguimientoTratamiento> addSeguimiento(int id, Map<String, dynamic> data) async {
    final response = await _dio.post('/tratamientos/$id/seguimientos', data: data);
    return SeguimientoTratamiento.fromJson(response.data);
  }
}
