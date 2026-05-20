import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  Future<Either<AppFailure, User>> call({
    required String email,
    required String password,
  }) =>
      _repository.login(email: email, password: password);
}
