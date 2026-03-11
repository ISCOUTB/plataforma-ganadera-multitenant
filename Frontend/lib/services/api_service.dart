import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';
  final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/usuarios/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> registro(String email, String password, String nombre) async {
    final response = await _dio.post('/usuarios/registro', data: {
      'email': email,
      'password': password,
      'nombre': nombre,
      'tenant_id': 'finca1',
    });
    return response.data;
  }
}
