import 'package:equatable/equatable.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

/// Event triggered when user sends a new chat message.
///
/// This event includes the message content and context (tenant and finca IDs)
/// needed to route the message to the correct farm and tenant.
class SendChatMessageEvent extends ChatEvent {
  final String message;
  final String tenantId;
  final String fincaId;

  const SendChatMessageEvent({
    required this.message,
    required this.tenantId,
    required this.fincaId,
  });

  @override
  List<Object?> get props => [message, tenantId, fincaId];
}

/// Event triggered when loading previous chat history.
///
/// Used on chat initialization to retrieve existing conversation history
/// for a specific tenant and farm.
class LoadChatHistoryEvent extends ChatEvent {
  final String tenantId;
  final String fincaId;

  const LoadChatHistoryEvent({
    required this.tenantId,
    required this.fincaId,
  });

  @override
  List<Object?> get props => [tenantId, fincaId];
}
