import 'dart:async';

import 'package:eClassify/features/chat/models/chat.dart';
import 'package:eClassify/features/chat/models/chat_message.dart';
import 'package:eClassify/features/chat/models/item_offer.dart';

sealed class ChatEvent {}

final class ChatReadEvent extends ChatEvent {
  ChatReadEvent(this.chatId, {this.itemId});

  final int chatId;
  final int? itemId;
}

final class ChatBlockedEvent extends ChatEvent {
  ChatBlockedEvent({
    required this.userId,
    this.isBlockedByMe,
    this.isBlockedByOther,
  });

  final int userId;
  final bool? isBlockedByMe;
  final bool? isBlockedByOther;
}

final class ChatMessageReceivedEvent extends ChatEvent {
  ChatMessageReceivedEvent({
    required this.message,
    this.itemOffer,
    this.chatUser,
    this.isReceiverSeller = false,
  });

  final ChatNotificationMessage message;
  final ItemOffer? itemOffer;
  final Chat? chatUser;
  final bool isReceiverSeller;
}

final class ChatDeletedEvent extends ChatEvent {
  ChatDeletedEvent({required this.itemOfferIds, this.itemId});

  final List<int> itemOfferIds;
  final int? itemId;
}

final class ChatMessageSentEvent extends ChatEvent {
  ChatMessageSentEvent({required this.message});

  final ChatMessage message;
}

final class ChatOfferUpdatedEvent extends ChatEvent {
  ChatOfferUpdatedEvent({required this.itemOfferId, required this.amount});

  final int itemOfferId;
  final String amount;
}

class ChatEventBus {
  ChatEventBus._internal();

  static final ChatEventBus _instance = ChatEventBus._internal();

  static ChatEventBus get instance => _instance;

  final StreamController<ChatEvent> _controller =
      StreamController<ChatEvent>.broadcast();

  Stream<ChatEvent> get eventStream => _controller.stream;

  void emit(ChatEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  void dispose() {
    _controller.close();
  }
}
