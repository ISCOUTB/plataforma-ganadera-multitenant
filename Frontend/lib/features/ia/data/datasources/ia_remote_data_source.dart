import 'package:dio/dio.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../models/chat_message_model.dart';
import '../models/prediction_model.dart';
import '../models/recommendation_model.dart';
import '../../domain/entities/chat_message.dart';

class IaRemoteDataSource {
  final Dio _dio;

  IaRemoteDataSource(this._dio);

  Future<ChatMessageModel> sendChatMessage({
    required String message,
    required String tenantId,
    required String fincaId,
    List<ChatMessageModel>? chatHistory,
  }) async {
    try {
      final messages = <Map<String, dynamic>>[];
      if (chatHistory != null && chatHistory.isNotEmpty) {
        messages.addAll(chatHistory.map((m) => {
          'role': m.role.apiValue,
          'content': m.content,
        }));
      }
      messages.add({
        'role': 'user',
        'content': message,
      });

      final response = await _dio.post(
        '/ai/chat',
        data: {'messages': messages},
        options: Options(
          headers: {
            'X-Tenant-ID': tenantId,
          },
        ),
      );

      final responseData = response.data as Map<String, dynamic>;
      final responseWrapper = responseData['response'] as Map<String, dynamic>?;

      if (responseWrapper != null) {
        return ChatMessageModel.fromJson(responseWrapper);
      }

      return ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: ChatMessageRole.assistant,
        content: responseData['response'] as String? ?? '',
        timestamp: DateTime.now(),
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    } catch (e) {
      throw UnknownFailure('Error sending chat message: ${e.toString()}');
    }
  }

  Future<PredictionModel> getPredictions({
    required String metric,
    required List<double> values,
    required String tenantId,
    required String fincaId,
    int steps = 30,
  }) async {
    try {
      final response = await _dio.post(
        '/ai/predict',
        data: {
          'metric': metric,
          'values': values,
          'steps': steps,
        },
        options: Options(
          headers: {
            'X-Tenant-ID': tenantId,
          },
        ),
      );

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>?;

      if (data != null) {
        return PredictionModel.fromJson(data);
      }

      return PredictionModel.fromJson(responseData);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    } catch (e) {
      throw UnknownFailure('Error getting predictions: ${e.toString()}');
    }
  }

  Future<List<RecommendationModel>> getRecommendations({
    required String tenantId,
    required String fincaId,
  }) async {
    try {
      final response = await _dio.get(
        '/ai/recommendations',
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

  Future<bool> checkHealthStatus({
    required String tenantId,
  }) async {
    try {
      final response = await _dio.get(
        '/ai/health',
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
