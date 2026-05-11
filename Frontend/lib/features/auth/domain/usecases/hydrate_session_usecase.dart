import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Decide el estado inicial al arrancar la app:
/// - Si NO hay tokens guardados → `null` (= unauthenticated).
/// - Si hay tokens → llama `/auth/me` y devuelve el usuario.
///   Si `/auth/me` falla con 401, el `AuthInterceptor` ya intentó refresh;
///   si éste también falló, regresa `Left(failure)`.
class HydrateSessionUseCase {
  final AuthRepository _repository;
  final SecureStorageService _storage;

  HydrateSessionUseCase({
    required AuthRepository repository,
    required SecureStorageService storage,
  })  : _repository = repository,
        _storage = storage;

  Future<Either<AppFailure, User?>> call() async {
    final hasSession = await _storage.hasSession();
    if (!hasSession) return const Right(null);

    final result = await _repository.getMe();
    return result.fold(
      (failure) async {
        await _storage.clear();
        return Left(failure);
      },
      (user) => Right(user),
    );
  }
}
