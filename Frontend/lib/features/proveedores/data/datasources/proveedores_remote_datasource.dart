import 'package:dio/dio.dart';
import '../../domain/entities/proveedor.dart';

class ProveedoresRemoteDataSource {
  final Dio _dio;
  ProveedoresRemoteDataSource(this._dio);

  Future<List<Proveedor>> getAll() async {
    final response = await _dio.get('/proveedores');
    return (response.data as List).map((e) => Proveedor.fromJson(e)).toList();
  }

  Future<Proveedor> getOne(int id) async {
    final response = await _dio.get('/proveedores/$id');
    return Proveedor.fromJson(response.data);
  }

  Future<Proveedor> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/proveedores', data: data);
    return Proveedor.fromJson(response.data);
  }

  Future<Proveedor> update(int id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/proveedores/$id', data: data);
    return Proveedor.fromJson(response.data);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/proveedores/$id');
  }

  Future<ProveedorPrecio> addPrecio(int id, Map<String, dynamic> data) async {
    final response = await _dio.post('/proveedores/$id/precios', data: data);
    return ProveedorPrecio.fromJson(response.data);
  }

  Future<void> deletePrecio(int precioId) async {
    await _dio.delete('/proveedores/precios/$precioId');
  }

  Future<List<ProveedorPrecio>> getComparador(String fkIdAlimento) async {
    final response = await _dio.get('/proveedores/comparador', queryParameters: {'alimento': fkIdAlimento});
    return (response.data as List).map((e) => ProveedorPrecio.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getAlimentos() async {
    final response = await _dio.get('/alimentos');
    final data = response.data;
    if (data is Map && data['data'] != null) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return (data as List).cast<Map<String, dynamic>>();
  }
}