import '../../domain/entities/chat_message.dart';

/// Data model for [ChatMessage] with JSON serialization support.
///
/// Extends the domain [ChatMessage] entity and adds serialization/deserialization
/// capabilities for API communication.
class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.role,
    required super.content,
    required super.timestamp,
    super.error,
    super.isLoading,
  });

  /// Creates a [ChatMessageModel] from a JSON map.
  ///
  /// Handles various JSON formats and provides sensible defaults:
  /// - `id`: defaults to current milliseconds since epoch if missing
  /// - `role`: parses using [ChatMessageRoleX.fromApi], defaults to 'assistant'
  /// - `content`: defaults to empty string if missing
  /// - `timestamp`: parses as DateTime, defaults to now if missing or invalid
  /// - `error`: optional error message
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final timestamp = _parseDate(json['timestamp']);
    
    return ChatMessageModel(
      id: (json['id'] as String?) ?? DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatMessageRoleX.fromApi(json['role'] as String?),
      content: (json['content'] as String?) ?? '',
      timestamp: timestamp ?? DateTime.now(),
      error: json['error'] as String?,
    );
  }

  /// Converts this model to a JSON map suitable for API calls.
  ///
  /// Returns a map with snake_case keys matching API conventions.
  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.apiValue,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'error': error,
      };

  /// Creates a copy of this model with optionally overridden fields.
  ///
  /// Useful for immutable updates to specific fields without replacing
  /// the entire object.
  ChatMessageModel copyWith({
    String? id,
    ChatMessageRole? role,
    String? content,
    DateTime? timestamp,
    String? error,
    bool? isLoading,
  }) =>
      ChatMessageModel(
        id: id ?? this.id,
        role: role ?? this.role,
        content: content ?? this.content,
        timestamp: timestamp ?? this.timestamp,
        error: error ?? this.error,
        isLoading: isLoading ?? this.isLoading,
      );

  /// Parses a dynamic value as a [DateTime].
  ///
  /// Handles null, empty strings, and invalid formats gracefully.
  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is String && raw.isEmpty) return null;
    return DateTime.tryParse(raw.toString());
  }
}
