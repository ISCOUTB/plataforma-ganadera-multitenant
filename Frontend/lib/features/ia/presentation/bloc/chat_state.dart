import 'package:equatable/equatable.dart';

import '../../domain/entities/chat_message.dart';

sealed class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

/// Initial state when chat feature first loads.
///
/// Used as the starting point before any user interaction or API call.
class ChatInitialState extends ChatState {
  const ChatInitialState();
}

/// State emitted while waiting for API response.
///
/// Used during message sending or history loading operations
/// to indicate the application is processing a request.
class ChatLoadingState extends ChatState {
  const ChatLoadingState();
}

/// State emitted after successful chat operation.
///
/// Holds the complete list of chat messages accumulated during the session.
/// This includes both user and assistant messages.
class ChatSuccessState extends ChatState {
  final List<ChatMessage> messages;

  const ChatSuccessState(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// State emitted when a chat operation fails.
///
/// Holds the error message describing what went wrong during the API call
/// or message processing.
class ChatErrorState extends ChatState {
  final String message;

  const ChatErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
