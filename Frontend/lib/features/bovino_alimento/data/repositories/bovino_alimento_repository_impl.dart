import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/bovino_alimento.dart';
import '../../domain/repositories/bovino_alimento_repository.dart';
import '../datasources/bovino_alimento_remote_datasource.dart';

class BovinoAlimentoRepositoryImpl implements BovinoAlimentoRepository {
  final BovinoAlimentoRemoteDataSource _remote;
  BovinoAlimentoRepositoryImpl({required BovinoAlimentoRemoteDataSource remote})
      : _remote = remote;

  AppFailure _toFailure(DioException e) {
    final err = e.error;
    if (err is AppFailure) return err;
    return const UnknownFailure();
  }

  Future<Either<AppFailure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } on DioException catch (e) {
      return Left(_toFailure(e));
    } catch (_) {
      return const Left(
        UnknownFailure('Error procesando la respuesta del servidor'),
      );
    }
  }

  @override
  Future<Either<AppFailure, List<BovinoAlimento>>> getByAnimal(int animalId) =>
      _guard(() async {
        final items = await _remote.getByAnimal(animalId);
        return items.map((m) => m.toEntity()).toList();
      });

  @override
  Future<Either<AppFailure, BovinoAlimento>> assign(
    AsignarBovinoAlimentoInput input,
  ) =>
      _guard(() async {
        final model = await _remote.assign(
          animalId: input.animalId,
          alimentoId: input.alimentoId,
          cantidad: input.cantidad,
          fecha: input.fecha,
        );
        return model.toEntity();
      });

  @override
  Future<Either<AppFailure, Unit>> remove(int animalId, String alimentoId) =>
      _guard(() async {
        await _remote.remove(animalId, alimentoId);
        return unit;
      });
}
