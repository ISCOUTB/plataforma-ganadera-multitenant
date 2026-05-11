import 'package:dio/dio.dart';

import '../../domain/entities/usuario_tenant.dart';
import '../models/usuario_tenant_model.dart';

class UsuariosRemoteDataSource {
  final Dio _dio;
  UsuariosRemoteDataSource(this._dio);

  Future<List<UsuarioTenant>> list() async {
    final response = await _dio.get('/usuarios');
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => UsuarioTenantModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }

  Future<UsuarioTenant> create({
    required String email,
    required String password,
    required String nombre,
    String? telefono,
    String? rol,
  }) async {
    final response = await _dio.post(
      '/usuarios',
      data: {
        'email': email,
        'password': password,
        'nombre': nombre,
        if (telefono != null) 'telefono': telefono,
        if (rol != null) 'rol': rol,
      },
    );
    return UsuarioTenantModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UsuarioTenant> update(
    int id, {
    String? nombre,
    String? telefono,
    String? rol,
  }) async {
    final response = await _dio.patch(
      '/usuarios/$id',
      data: {
        if (nombre != null) 'nombre': nombre,
        if (telefono != null) 'telefono': telefono,
        if (rol != null) 'rol': rol,
      },
    );
    return UsuarioTenantModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> remove(int id) async {
    await _dio.delete('/usuarios/$id');
  }
}
