import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/auth_response_dto.dart';
import '../models/user_model.dart';

/// Datasource HTTP de auth.
///
/// **FARMLINK_RULE**: el único método que envía `tenant_id` es `register()`
/// (porque `/auth/registro` es público y necesita saber a qué tenant
/// pertenece el nuevo usuario). Ningún otro método del proyecto puede mandar
/// `tenant_id` — viaja firmado dentro del JWT.
class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<AuthResponseDto> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.authLogin,
      data: {'email': email, 'password': password},
    );
    return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String nombre,
    required String tenantId,
    String? telefono,
  }) async {
    // FARMLINK_RULE: tenant_id solo se manda aquí.
    final response = await _dio.post(
      ApiEndpoints.authRegister,
      data: {
        'email': email,
        'password': password,
        'nombre': nombre,
        'tenant_id': tenantId,
        if (telefono != null) 'telefono': telefono,
      },
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get(ApiEndpoints.authMe);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _dio.post(ApiEndpoints.authLogout);
  }
}
