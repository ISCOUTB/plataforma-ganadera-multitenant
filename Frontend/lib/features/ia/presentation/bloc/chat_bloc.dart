import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ia_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

/// BLoC for managing chat interactions with the AI service.
///
/// This BLoC handles sending chat messages and loading chat history,
/// maintaining a session-level list of messages that persists throughout
/// the chat session.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final IaRepository _repository;
  final List<ChatMessage> _messages = [];
  int _messageCounter = 0;

  ChatBloc({required IaRepository repository})
      : _repository = repository,
        super(const ChatInitialState()) {
    on<SendChatMessageEvent>(_onSendChatMessage);
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
  }

  /// Generates a unique message ID using timestamp and counter.
  String _generateMessageId() {
    _messageCounter++;
    return '${DateTime.now().millisecondsSinceEpoch}_$_messageCounter';
  }

  /// Handles sending a chat message to the AI service.
  ///
  /// Flow:
  /// 1. Emit loading state
  /// 2. Call repository to send message
  /// 3. On success: create ChatMessage, add to internal list, emit success state
  /// 4. On failure: emit error state with failure message
  Future<void> _onSendChatMessage(
    SendChatMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoadingState());

    final result = await _repository.sendChatMessage(
      message: event.message,
      tenantId: event.tenantId,
      context: event.fincaId,
    );

    result.fold(
      (failure) {
        emit(ChatErrorState(failure.message));
      },
      (responseMessage) {
        // Add user message first
        final userMessage = ChatMessage(
          id: _generateMessageId(),
          role: ChatMessageRole.user,
          content: event.message,
          timestamp: DateTime.now(),
        );
        _messages.add(userMessage);

        // Add assistant response
        _messages.add(responseMessage);

        emit(ChatSuccessState(List.unmodifiable(_messages)));
      },
    );
  }

  /// Handles loading chat history for a specific tenant and farm.
  ///
  /// Flow:
  /// 1. Emit loading state
  /// 2. In demo mode, just clear messages and emit empty success state
  /// 3. On failure: emit error state with failure message
  ///
  /// Note: This can be extended in the future to load cached history
  /// or retrieve historical messages from the backend.
  Future<void> _onLoadChatHistory(
    LoadChatHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoadingState());

    // In demo/initial mode, clear messages and emit empty state
    // This prepares the BLoC for a new chat session
    _messages.clear();
    emit(const ChatSuccessState([]));

    // Note: Future enhancement - add history retrieval logic:
    // final result = await _repository.getChatHistory(
    //   tenantId: event.tenantId,
    //   fincaId: event.fincaId,
    // );
    // result.fold(
    //   (failure) => emit(ChatErrorState(failure.message)),
    //   (history) {
    //     _messages.addAll(history);
    //     emit(ChatSuccessState(List.unmodifiable(_messages)));
    //   },
    // );
  }
}
