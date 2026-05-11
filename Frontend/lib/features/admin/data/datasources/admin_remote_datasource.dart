import 'package:dio/dio.dart';

import '../../domain/entities/admin_user.dart';
import '../../domain/entities/tenant_summary.dart';
import '../models/admin_user_model.dart';
import '../models/tenant_summary_model.dart';

class AdminRemoteDataSource {
  final Dio _dio;
  AdminRemoteDataSource(this._dio);

  Future<List<TenantSummary>> listTenants() async {
    final response = await _dio.get('/admin/tenants');
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => TenantSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }

  Future<List<AdminUser>> listAllUsers() async {
    final response = await _dio.get('/admin/users');
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => AdminUserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }

  Future<AdminUser> createUser({
    required String email,
    required String password,
    required String nombre,
    required String tenantId,
    String? rol,
    String? telefono,
  }) async {
    final response = await _dio.post('/admin/create-user', data: {
      'email': email,
      'password': password,
      'nombre': nombre,
      'tenant_id': tenantId,
      if (rol != null) 'rol': rol,
      if (telefono != null && telefono.isNotEmpty) 'telefono': telefono,
    });
    return AdminUserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
