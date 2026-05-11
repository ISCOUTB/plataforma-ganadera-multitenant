import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetMeUseCase {
  final AuthRepository _repository;
  GetMeUseCase(this._repository);

  Future<Either<AppFailure, User>> call() => _repository.getMe();
}
