import 'dart:async';

import 'package:collection/collection.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/auth/session_scoped.dart';
import 'package:eClassify/features/chat/models/chat.dart';
import 'package:eClassify/features/chat/models/chat_message.dart';
import 'package:eClassify/features/chat/repository/chat_history_repository.dart';
import 'package:eClassify/features/chat/services/chat_event_bus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ChatListState {}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListSuccess extends ChatListState {
  ChatListSuccess({required this.users})
    : item = users.firstOrNull?.item,
      unreadCount = users.fold(
        0,
        (value, user) => value += (user.unreadCount > 0 ? 1 : 0),
      );
  final List<Chat> users;
  final ChatItem? item;
  final int unreadCount;
}

class ChatListFailure extends ChatListState {
  ChatListFailure({required this.error});

  final Object error;
}

abstract class ChatListCubit extends Cubit<ChatListState> with SessionScoped {
  ChatListCubit() : super(ChatListInitial()) {
    _eventSubscription = ChatEventBus.instance.eventStream.listen(_onChatEvent);
  }

  bool canProcessEvent(ChatEvent event);

  int page = 1;
  bool hasMore = true;
  bool isLoadingMore = false;
  List<Chat>? _preDeletionUsers;
  List<Chat>? _cachedUsers;
  String? search;
  late final StreamSubscription _eventSubscription;

  void _onChatEvent(ChatEvent event) {
    if (state is! ChatListSuccess) return;
    if (!canProcessEvent(event)) return;
    Log.debug('ChatListCubit._onChatEvent: $event');

    try {
      switch (event) {
        case ChatReadEvent(:final chatId):
          removeUnreadCount(chatId);
        case ChatBlockedEvent(
          :final userId,
          :final isBlockedByMe,
          :final isBlockedByOther,
        ):
          toggleBlockStatus(
            userId: userId,
            isUserBlocked: isBlockedByMe,
            isBlockedByOtherUser: isBlockedByOther,
          );
        case ChatMessageReceivedEvent(:final message, :final chatUser):
          final didUpdate = updateChat(message);
          if (!didUpdate && chatUser != null) {
            // New chat: count the same way an existing one does (this one
            // message, or 0 if the chat is open) instead of trusting the
            // payload's unread_count, which has reported 2 for a first
            // offer.
            addChatUser(chatUser.copyWith(unreadCount: message.unreadCount));
          }
        case ChatDeletedEvent(:final itemOfferIds):
          removeChatsLocally(itemOfferIds);
        case ChatOfferUpdatedEvent(:final itemOfferId, :final amount):
          updateOfferAmount(itemOfferId, amount);
        case ChatMessageSentEvent(:final message):
          updateFromSentMessage(message);
      }
    } catch (e, st) {
      Log.error('Error in ChatListCubit._onChatEvent', e, st);
    }
  }

  Future<Json> fetch(int page, {String? search});

  Future<void> getChatUsers({String? search}) async {
    try {
      this.search = search;
      if (search.isNotNullAndNotEmpty) {
        _cachedUsers ??= (state as ChatListSuccess).users;
        emit(ChatListLoading());
        final response = await fetch(1, search: search);
        final users = response['chats'] as List<Chat>;
        emit(ChatListSuccess(users: users));
      } else {
        if (_cachedUsers.isNotNullAndNotEmpty) {
          emit(ChatListSuccess(users: _cachedUsers!));
          _cachedUsers = null;
        } else {
          emit(ChatListLoading());

          final response = await fetch(page);

          final users = response['chats'] as List<Chat>;
          hasMore = response['has_more'] as bool;
          emit(ChatListSuccess(users: users));
        }
      }
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(ChatListFailure(error: e));
    }
  }

  Future<void> getMoreChatUsers() async {
    if (state is! ChatListSuccess ||
        !hasMore ||
        isLoadingMore ||
        (search != null && search!.isNotEmpty))
      return;
    try {
      isLoadingMore = true;
      final response = await fetch(page + 1);

      final users = response['chats'] as List<Chat>;

      emit(
        ChatListSuccess(users: [...(state as ChatListSuccess).users, ...users]),
      );

      hasMore = response['has_more'] as bool;
      if (hasMore) ++page;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(ChatListFailure(error: e));
    } finally {
      isLoadingMore = false;
    }
  }

  List<Chat> _getChats() {
    if (state is! ChatListSuccess) return [];
    return (state as ChatListSuccess).users;
  }

  void removeUnreadCount(int chatId) {
    final chats = List<Chat>.from(_getChats());
    final index = chats.indexWhere((element) => element.id == chatId);
    if (index != -1) {
      chats[index] = chats[index].copyWith(unreadCount: 0);
    }
    emit(ChatListSuccess(users: chats));
  }

  bool updateChat(ChatNotificationMessage message) {
    final chats = List<Chat>.from(_getChats());
    final index = chats.indexWhere((element) => element.id == message.id);
    if (index == -1) return false;
    if (index != 0) {
      final newUser = chats[index].fromChatNotification(message);
      chats.removeAt(index);
      emit(ChatListSuccess(users: [newUser, ...chats]));
    } else {
      chats[index] = chats[index].fromChatNotification(message);
      emit(ChatListSuccess(users: chats));
    }
    return true;
  }

  /// Mirrors [updateChat] for messages this user sent: refresh the preview
  /// and bump the chat to the top. Unread count is untouched.
  void updateFromSentMessage(ChatMessage message) {
    final chats = List<Chat>.from(_getChats());
    final index = chats.indexWhere((element) => element.id == message.chatId);
    if (index == -1) return;
    final updated = chats.removeAt(index).fromSentMessage(message);
    emit(ChatListSuccess(users: [updated, ...chats]));
  }

  void removeChatsLocally(List<int> ids) {
    final currentChats = _getChats();
    _preDeletionUsers = List.from(currentChats);
    final updatedChats = currentChats
        .where((chat) => !ids.contains(chat.id))
        .toList();
    emit(ChatListSuccess(users: updatedChats));
  }

  void rollbackDeletion() {
    if (_preDeletionUsers != null) {
      emit(ChatListSuccess(users: _preDeletionUsers!));
      _preDeletionUsers = null;
    }
  }

  void commitDeletion() {
    _preDeletionUsers = null;
  }

  // Only for backwards compatibility with existing chat system
  // Remove after refactoring to new chat system
  Chat? getChatFromItemId(int itemId) {
    if (state is! ChatListSuccess) return null;
    return (state as ChatListSuccess).users.firstWhereOrNull((element) {
      return element.item.id == itemId;
    });
  }

  void addChatUser(Chat chat) {
    emit(ChatListSuccess(users: List.from([chat, ..._getChats()])));
  }

  void toggleBlockStatus({
    required int userId,
    bool? isUserBlocked,
    bool? isBlockedByOtherUser,
  }) {
    Log.debug(
      'ChatListCubit.toggleBlockStatus: $userId, $isUserBlocked, $isBlockedByOtherUser',
    );
    final currentChats = _getChats();
    bool updated = false;

    final updatedChats = currentChats.map((chat) {
      if (chat.sellerId == userId || chat.buyerId == userId) {
        updated = true;
        return chat.copyWith(
          isUserBlocked: isUserBlocked,
          isBlockedByOtherUser: isBlockedByOtherUser,
        );
      }
      return chat;
    }).toList();

    if (!updated) {
      Log.debug('ChatListCubit.toggleBlockStatus: No chats found for $userId');
      return;
    }

    emit(ChatListSuccess(users: updatedChats));
  }

  void updateOfferAmount(int offerId, String amount) {
    final currentChats = _getChats();
    final chat = currentChats.firstWhereOrNull(
      (element) => element.id == offerId,
    );
    if (chat == null) return;
    final updated = chat.copyWith(formattedAmount: amount);
    final index = currentChats.indexOf(chat);
    currentChats[index] = updated;
    emit(ChatListSuccess(users: currentChats));
  }

  void clear() => emit(ChatListInitial());

  @override
  void clearSessionState() => clear();

  @override
  Future<void> close() {
    _eventSubscription.cancel();
    return super.close();
  }
}

final class SellerChatListCubit extends ChatListCubit {
  SellerChatListCubit(this.itemId) : super();
  final int itemId;

  @override
  bool canProcessEvent(ChatEvent event) {
    switch (event) {
      case ChatMessageReceivedEvent(:final isReceiverSeller, :final message):
        return isReceiverSeller && message.itemId == itemId;
      case ChatReadEvent(itemId: final eventItemId):
        return eventItemId == itemId;
      default:
        return true;
    }
  }

  @override
  Future<Json> fetch(int page, {String? search}) => ChatHistoryRepository
      .instance
      .getSellerItemChats(itemId: itemId, page: page, search: search);
}

final class BuyingChatListCubit extends ChatListCubit {
  @override
  bool canProcessEvent(ChatEvent event) {
    if (event case ChatMessageReceivedEvent(:final isReceiverSeller)) {
      return !isReceiverSeller;
    }
    return true;
  }

  @override
  Future<Json> fetch(int page, {String? search}) => ChatHistoryRepository
      .instance
      .getBuyerItemChats(page: page, search: search);
}
