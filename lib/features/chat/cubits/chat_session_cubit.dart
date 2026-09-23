import 'dart:async';

import 'package:eClassify/features/chat/models/chat.dart';
import 'package:eClassify/features/chat/services/audio_service.dart';
import 'package:eClassify/features/chat/services/chat_event_bus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatSessionState {
  ChatSessionState({
    required this.chat,
    required this.isCurrentUserSeller,
    bool? isBlockedByOther,
    this.showTemplates = true,
  }) : isBlockedByOther = isBlockedByOther ?? chat.isBlockedByOtherUser,
       currentOffer = chat.formattedAmount;

  final Chat chat;
  final bool isCurrentUserSeller;
  final bool isBlockedByOther;
  final bool showTemplates;
  final String? currentOffer;

  bool get isBlockedByMe => chat.isUserBlocked;

  ChatSessionState copyWith({
    Chat? chat,
    bool? isBlockedByOther,
    bool? showTemplates,
  }) => ChatSessionState(
    chat: chat ?? this.chat,
    isCurrentUserSeller: isCurrentUserSeller,
    isBlockedByOther: isBlockedByOther ?? this.isBlockedByOther,
    showTemplates: showTemplates ?? this.showTemplates,
  );
}

class ChatSessionCubit extends Cubit<ChatSessionState> {
  ChatSessionCubit(this.chat, {bool isCurrentUserSeller = true})
    : audioService = AudioService(),
      super(
        ChatSessionState(chat: chat, isCurrentUserSeller: isCurrentUserSeller),
      ) {
    _eventSubscription = ChatEventBus.instance.eventStream.listen(_onChatEvent);
  }

  final Chat chat;
  final AudioService audioService;
  late final StreamSubscription _eventSubscription;

  void _onChatEvent(ChatEvent event) {
    switch (event) {
      case ChatBlockedEvent(
        :final userId,
        :final isBlockedByMe,
        :final isBlockedByOther,
      ):
        final otherId = state.isCurrentUserSeller
            ? chat.buyerId
            : chat.sellerId;

        if (userId == otherId) {
          if (isBlockedByMe != null) {
            setBlockedByMeStatus(isBlockedByMe);
          }
          if (isBlockedByOther != null) {
            setBlockedByOtherStatus(isBlockedByOther);
          }
        }
      case ChatMessageSentEvent():
        toggleTemplates(false);
      case ChatOfferUpdatedEvent(:final itemOfferId, :final amount):
        if (itemOfferId == chat.id) updateOffer(amount);
      default:
        break;
    }
  }

  bool get isBlockedByMe {
    return state.isBlockedByMe;
  }

  bool get isBlockedByOther {
    return state.isBlockedByOther;
  }

  void setBlockedByMeStatus(bool isBlocked) {
    final chat = state.chat.copyWith(isUserBlocked: isBlocked);
    emit(state.copyWith(chat: chat));
  }

  void setBlockedByOtherStatus(bool isBlocked) {
    emit(state.copyWith(isBlockedByOther: isBlocked));
  }

  void updateOffer(String offer) {
    emit(state.copyWith(chat: state.chat.copyWith(formattedAmount: offer)));
  }

  void toggleTemplates([bool? showTemplates]) {
    emit(state.copyWith(showTemplates: showTemplates ?? !state.showTemplates));
  }

  @override
  Future<void> close() {
    _eventSubscription.cancel();
    audioService.dispose();
    return super.close();
  }
}
