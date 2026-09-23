import 'dart:async';
import 'dart:io';

import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/chat/models/chat_message.dart';
import 'package:eClassify/features/chat/repository/chat_repository.dart';
import 'package:eClassify/features/chat/services/chat_event_bus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatMessageState {
  ChatMessageState({
    required this.messages,
    required this.isLoading,
    required this.error,
  });

  factory ChatMessageState.initial() =>
      ChatMessageState(messages: List.empty(), isLoading: false, error: null);

  final List<ChatMessage> messages;
  final bool isLoading;
  final Object? error;

  bool get hasError => error != null;

  ChatMessageState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    Object? error,
  }) => ChatMessageState(
    messages: messages ?? this.messages,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );

  @override
  String toString() {
    return 'ChatMessageState{messages: ${messages.length}, isLoading: $isLoading, error: $error}';
  }
}

class ChatMessageCubit extends Cubit<ChatMessageState> {
  ChatMessageCubit(this.chatId) : super(ChatMessageState.initial());
  final int chatId;
  final _repository = ChatRepository.instance;
  int? _senderId;

  int page = 0;
  bool hasMore = true;

  /// In-flight lock, same idea as `PaginatedCubit` (see
  /// .claude/decisions/paginated-cubit.md): the scroll listener fires on
  /// every ScrollNotification and `page` only advances after the response,
  /// so without this the same page is requested several times and each
  /// response is appended — duplicate messages when scrolling up.
  bool _isFetching = false;

  /// Tracks the last emitted progress percentage to throttle UI updates.
  final Map<String, double> _lastEmittedProgress = {};

  /// Set when a message arrives live while this chat is open. Those are
  /// shown as read locally but the server only marks messages read when
  /// they are fetched, so [close] refetches page 1 to sync it.
  bool _receivedWhileOpen = false;

  Future<void> getMessages() async {
    if (_isFetching || !hasMore) return;
    _isFetching = true;
    try {
      emit(state.copyWith(isLoading: true));

      final response = await _repository.getMessages(
        chatId: chatId,
        page: page + 1,
      );

      // Messages that arrived live (notification / optimistic send) while
      // this page was in flight can also be in the page — keep one copy.
      final known = {
        for (final m in state.messages)
          if (m.id != null) m.id,
      };
      final fresh = response.data.where(
        (m) => m.id == null || !known.contains(m.id),
      );

      emit(
        state.copyWith(
          messages: [...state.messages, ...fresh],
          isLoading: false,
        ),
      );
      // Empty page ends pagination even if `total` says otherwise — live
      // messages counted in the list can leave the length short of it.
      hasMore =
          response.data.isNotEmpty && response.total > state.messages.length;
      if (hasMore) ++page;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(state.copyWith(error: e, isLoading: false));
    } finally {
      // Hold the lock a frame longer so the notification that fires before
      // the appended items are laid out doesn't re-trigger the next page.
      await Future.delayed(const Duration(milliseconds: 300));
      _isFetching = false;
    }
  }

  /// Sends a message optimistically and handles status/progress updates.
  Future<void> sendMessage({
    String? text,
    File? audio,
    File? attachment,
    String? offer,
    String? formattedOffer,
  }) async {
    _senderId ??= AppSession.currentUser!.id;

    // 1. Create local message placeholder using the Factory
    final localMessage = ChatMessageFactory.fromLocal(
      chatId: chatId,
      senderId: _senderId!,
      text: text,
      audio: audio,
      attachment: attachment,
      offer: offer,
      formattedOffer: formattedOffer,
    );

    final localId = localMessage.localId!;

    // 2. Optimistic Update: Add to the start of the list
    emit(state.copyWith(messages: [localMessage, ...state.messages]));

    ChatEventBus.instance.emit(ChatMessageSentEvent(message: localMessage));

    try {
      // 3. Call Repository using the message object directly
      final confirmedMessage = await _repository.sendMessage(
        localMessage,
        onProgress: (progress) {
          if (localMessage is TextChatMessage) return;
          _onUploadProgress(localId, progress);
        },
      );

      _updateMessage(localId, confirmedMessage);
      _lastEmittedProgress.remove(localId);

      // Second pass for the inbox: the confirmed message carries the
      // server's preview wording.
      ChatEventBus.instance.emit(
        ChatMessageSentEvent(message: confirmedMessage),
      );

      // The server's formatted amount is the one the offer bar and the
      // inbox row should show, not the locally typed text.
      if (confirmedMessage case OfferChatMessage(:final amount)) {
        ChatEventBus.instance.emit(
          ChatOfferUpdatedEvent(itemOfferId: chatId, amount: amount),
        );
      }
    } on Exception catch (e, st) {
      // 5. Update Failure
      if (e.toString() == 'blocked_by_other_user') {
        _removeMessage(localId);
        emit(state.copyWith(error: e));
      } else {
        final msg = _findMessage(localId);
        if (msg != null) {
          _updateMessage(localId, msg.withStatus(MessageSendingStatus.failed));
        }
      }
      _lastEmittedProgress.remove(localId);
      Log.error(e.toString(), e, st);
    }
  }

  /// Retries a previously failed message.
  Future<void> retryMessage(String localId) async {
    final message = _findMessage(localId);
    if (message == null || !message.isFailed) return;

    // Reset status to sending
    _updateMessage(localId, message.withStatus(MessageSendingStatus.sending));

    try {
      final confirmedMessage = await _repository.sendMessage(
        message,
        onProgress: (progress) {
          if (message is TextChatMessage) return;
          _onUploadProgress(localId, progress);
        },
      );
      _updateMessage(localId, confirmedMessage);
      _lastEmittedProgress.remove(localId);
      ChatEventBus.instance.emit(
        ChatMessageSentEvent(message: confirmedMessage),
      );
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      _updateMessage(localId, message.withStatus(MessageSendingStatus.failed));
      _lastEmittedProgress.remove(localId);
    }
  }

  /// Adds a message received from a real-time source (e.g. Notification).
  /// Handles deduplication and matching with local optimistic messages.
  void addIncomingMessage(ChatMessage message) {
    // 1. Check if message already exists by server ID
    if (message.id != null && state.messages.any((m) => m.id == message.id)) {
      return;
    }

    // 2. Check if it matches a local optimistic message
    if (message.localId != null) {
      final existing = _findMessage(message.localId!);
      if (existing != null) {
        // Replace the local placeholder with the server-confirmed version
        _updateMessage(message.localId!, message);
        _lastEmittedProgress.remove(message.localId);
        return;
      }
    }

    // 3. New message: prepend to list
    _receivedWhileOpen = true;
    emit(state.copyWith(messages: [message, ...state.messages]));
  }

  @override
  Future<void> close() {
    if (_receivedWhileOpen) {
      // Fire-and-forget: the response is irrelevant, the GET is what marks
      // the messages read server-side.
      unawaited(
        _repository
            .getMessages(chatId: chatId, page: 1)
            .then(
              (_) {},
              onError: (Object e, StackTrace st) =>
                  Log.error('Failed to mark chat $chatId read', e, st),
            ),
      );
    }
    return super.close();
  }

  /// Throttled progress updates to avoid jank.
  void _onUploadProgress(String localId, double progress) {
    final last = _lastEmittedProgress[localId] ?? 0.0;
    // Emit only if progress increased by > 20% or reached 100%
    if ((progress - last) > 0.2 || progress >= 0.99) {
      _lastEmittedProgress[localId] = progress;
      final message = _findMessage(localId);
      if (message != null) {
        _updateMessage(localId, message.withProgress(progress));
      }
    }
  }

  /// Helper to replace a message in the state list by localId.
  void _updateMessage(String localId, ChatMessage newMessage) {
    final updatedList = state.messages.map((m) {
      return m.localId == localId ? newMessage : m;
    }).toList();
    emit(state.copyWith(messages: updatedList));
  }

  /// Helper to find a specific message by localId.
  ChatMessage? _findMessage(String localId) {
    return state.messages.where((m) => m.localId == localId).firstOrNull;
  }

  void _removeMessage(String localId) {
    final updatedList = state.messages
        .where((m) => m.localId != localId)
        .toList();
    emit(state.copyWith(messages: updatedList));
  }

  Future<void> deleteMessages(int chatId, List<int> ids) async {
    final originalMessages = List<ChatMessage>.from(state.messages);

    // Optimistic Update
    final updatedList = state.messages
        .where((m) => !ids.contains(m.id))
        .toList();
    emit(state.copyWith(messages: updatedList));

    try {
      await _repository.deleteMessages(chatId, ids);
    } catch (e, st) {
      // Revert if failed
      emit(state.copyWith(messages: originalMessages));
      Log.error('Failed to delete messages', e, st);
    }
  }
}
