import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/chat_message.dart';
import '../entities/prediction.dart';
import '../entities/recommendation.dart';

/// Abstract repository interface for AI-related operations.
///
/// This repository provides methods for interacting with AI services including
/// chat messaging, predictions, and recommendations for livestock management.
/// All methods return `Either<AppFailure, T>` following functional programming
/// patterns for error handling.
abstract class IaRepository {
  /// Sends a chat message to the AI service.
  ///
  /// Parameters:
  ///   - message: The chat message content
  ///   - tenantId: The tenant identifier
  ///   - context: Optional context information for the message
  ///
  /// Returns either a [ChatMessage] or an [AppFailure].
  Future<Either<AppFailure, ChatMessage>> sendChatMessage({
    required String message,
    required String tenantId,
    String? context,
  });

  /// Retrieves predictions for a specific farm.
  ///
  /// Parameters:
  ///   - tenantId: The tenant identifier
  ///   - fincaId: The farm identifier
  ///
  /// Returns either a list of [Prediction] or an [AppFailure].
  Future<Either<AppFailure, List<Prediction>>> getPredictions({
    required String tenantId,
    required String fincaId,
  });

  /// Retrieves recommendations for a specific farm.
  ///
  /// Parameters:
  ///   - tenantId: The tenant identifier
  ///   - fincaId: The farm identifier
  ///
  /// Returns either a list of [Recommendation] or an [AppFailure].
  Future<Either<AppFailure, List<Recommendation>>> getRecommendations({
    required String tenantId,
    required String fincaId,
  });

  /// Checks the health status of the AI service.
  ///
  /// Returns either true (healthy) or an [AppFailure].
  Future<Either<AppFailure, bool>> checkHealthStatus();
}
