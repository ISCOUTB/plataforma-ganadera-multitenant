import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/prediction.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/repositories/ia_repository.dart';
import '../datasources/ia_remote_data_source.dart';

/// Concrete implementation of [IaRepository] for AI-related operations.
///
/// This repository implements the abstract [IaRepository] interface and
/// handles communication with the remote AI data source, including error
/// handling and entity conversion.
class IaRepositoryImpl implements IaRepository {
  final IaRemoteDataSource _remoteDataSource;

  IaRepositoryImpl({required IaRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  /// Converts a [DioException] to an [AppFailure].
  ///
  /// If the exception already contains an [AppFailure], it returns that.
  /// Otherwise, returns an [UnknownFailure].
  AppFailure _toFailure(DioException e) {
    final err = e.error;
    if (err is AppFailure) return err;
    return const UnknownFailure();
  }

  /// Guard function that wraps async operations with error handling.
  ///
  /// Catches [DioException] and other exceptions, converting them to
  /// [AppFailure] and wrapping the result in [Either].
  Future<Either<AppFailure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } on DioException catch (e) {
      return Left(_toFailure(e));
    } on AppFailure catch (e) {
      return Left(e);
    } catch (_) {
      return const Left(
        UnknownFailure('Error procesando la respuesta del servidor'),
      );
    }
  }

  @override
  Future<Either<AppFailure, ChatMessage>> sendChatMessage({
    required String message,
    required String tenantId,
    String? context,
  }) =>
      _guard(() async {
        final model = await _remoteDataSource.sendChatMessage(
          message: message,
          tenantId: tenantId,
          fincaId: '', // Default empty value when not provided
          chatHistory: null,
        );
        // Models already extend entities, so we can return them directly
        return model as ChatMessage;
      });

  @override
  Future<Either<AppFailure, List<Prediction>>> getPredictions({
    required String metric,
    required List<double> values,
    required String tenantId,
    required String fincaId,
    int steps = 30,
  }) =>
      _guard(() async {
        final model = await _remoteDataSource.getPredictions(
          metric: metric,
          values: values,
          tenantId: tenantId,
          fincaId: fincaId,
          steps: steps,
        );
        return [model as Prediction];
      });

  @override
  Future<Either<AppFailure, List<Recommendation>>> getRecommendations({
    required String tenantId,
    required String fincaId,
  }) =>
      _guard(() async {
        final models = await _remoteDataSource.getRecommendations(
          tenantId: tenantId,
          fincaId: fincaId,
        );
        // Models already extend entities, so we can return them directly
        return models.cast<Recommendation>();
      });

  @override
  Future<Either<AppFailure, bool>> checkHealthStatus() =>
      _guard(() async {
        // Placeholder tenant ID - in production, this should come from context
        const String tenantId = '';
        return await _remoteDataSource.checkHealthStatus(tenantId: tenantId);
      });
}
