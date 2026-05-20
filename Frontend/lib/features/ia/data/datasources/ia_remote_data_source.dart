import 'package:dio/dio.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../models/chat_message_model.dart';
import '../models/prediction_model.dart';
import '../models/recommendation_model.dart';

/// Remote data source for AI-related operations.
///
/// This class handles all HTTP communication with the backend AI endpoints.
/// All methods are designed to work within a multi-tenant architecture,
/// including tenant identification in request headers.
class IaRemoteDataSource {
  final Dio _dio;

  IaRemoteDataSource(this._dio);

  /// Sends a chat message to the AI service.
  ///
  /// Makes a POST request to `/api/ai/chat` with the message and optional
  /// chat history for context-aware responses.
  ///
  /// Parameters:
  ///   - message: The user's message content
  ///   - tenantId: The tenant identifier (added to headers)
  ///   - fincaId: The farm identifier (not used in current endpoint but provided for consistency)
  ///   - chatHistory: Optional list of previous messages for conversation context
  ///
  /// Returns a [ChatMessageModel] representing the AI response, or throws
  /// an [AppFailure] if the operation fails.
  Future<ChatMessageModel> sendChatMessage({
    required String message,
    required String tenantId,
    required String fincaId,
    List<ChatMessageModel>? chatHistory,
  }) async {
    try {
      final response = await _dio.post(
        '/api/ai/chat',
        data: {
          'message': message,
          if (chatHistory != null && chatHistory.isNotEmpty)
            'chat_history': chatHistory.map((m) => m.toJson()).toList(),
        },
        options: Options(
          headers: {
            'X-Tenant-ID': tenantId,
          },
        ),
      );

      return ChatMessageModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    } catch (e) {
      throw UnknownFailure('Error sending chat message: ${e.toString()}');
    }
  }

  /// Retrieves predictions from the AI service.
  ///
  /// Makes a POST request to `/api/ai/predict` with numerical data for analysis.
  ///
  /// Parameters:
  ///   - data: List of numerical values to predict on
  ///   - tenantId: The tenant identifier (added to headers)
  ///   - fincaId: The farm identifier (not used in current endpoint but provided for consistency)
  ///
  /// Returns a [PredictionModel] containing prediction values, labels, and confidence,
  /// or throws an [AppFailure] if the operation fails.
  Future<PredictionModel> getPredictions({
    required List<double> data,
    required String tenantId,
    required String fincaId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/ai/predict',
        data: {
          'data': data,
        },
        options: Options(
          headers: {
            'X-Tenant-ID': tenantId,
          },
        ),
      );

      return PredictionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    } catch (e) {
      throw UnknownFailure('Error getting predictions: ${e.toString()}');
    }
  }

  /// Retrieves recommendations from the AI service.
  ///
  /// Makes a GET request to `/api/ai/recommendations` to fetch AI-generated
  /// recommendations for a specific farm.
  ///
  /// Parameters:
  ///   - tenantId: The tenant identifier (added to headers)
  ///   - fincaId: The farm identifier (not used in current endpoint but provided for consistency)
  ///
  /// Returns a list of [RecommendationModel] objects, or throws an [AppFailure]
  /// if the operation fails.
  Future<List<RecommendationModel>> getRecommendations({
    required String tenantId,
    required String fincaId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/ai/recommendations',
        options: Options(
          headers: {
            'X-Tenant-ID': tenantId,
          },
        ),
      );

      final data = response.data;
      if (data is List) {
        return data
            .map((item) =>
                RecommendationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic>) {
        // Handle case where API wraps list in an object (e.g., { data: [...] })
        final list = data['data'] ?? data['recommendations'];
        if (list is List) {
          return list
              .map((item) =>
                  RecommendationModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    } catch (e) {
      throw UnknownFailure('Error getting recommendations: ${e.toString()}');
    }
  }

  /// Checks the health status of the AI service.
  ///
  /// Makes a GET request to `/api/ai/health` to verify that the AI service
  /// is operational and accessible.
  ///
  /// Returns true if the service is healthy, or throws an [AppFailure]
  /// if the operation fails.
  Future<bool> checkHealthStatus({
    required String tenantId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/ai/health',
        options: Options(
          headers: {
            'X-Tenant-ID': tenantId,
          },
        ),
      );

      final data = response.data as Map<String, dynamic>?;
      final status = data?['status'] as String?;

      return status == 'ok' || status == 'healthy' || status?.toLowerCase() == 'running';
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    } catch (e) {
      throw UnknownFailure('Error checking health status: ${e.toString()}');
    }
  }
}
