import 'package:equatable/equatable.dart';

enum ChatMessageRole { user, assistant }

extension ChatMessageRoleX on ChatMessageRole {
  String get apiValue => switch (this) {
        ChatMessageRole.user => 'user',
        ChatMessageRole.assistant => 'assistant',
      };

  static ChatMessageRole fromApi(String? raw) => switch (raw) {
        'assistant' => ChatMessageRole.assistant,
        _ => ChatMessageRole.user,
      };
}

class ChatMessage extends Equatable {
  final String id;
  final ChatMessageRole role;
  final String content;
  final DateTime timestamp;
  final String? error;
  final bool isLoading;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.error,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [
        id,
        role,
        content,
        timestamp,
        error,
        isLoading,
      ];
}
