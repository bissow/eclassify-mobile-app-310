import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/core/widgets/feedback/loading_overlay.dart';
import 'package:eClassify/features/chat/cubits/chat_message_cubit.dart';
import 'package:eClassify/features/chat/cubits/chat_session_cubit.dart';
import 'package:eClassify/features/chat/cubits/delete_chat_cubit.dart';
import 'package:eClassify/features/chat/cubits/user_block_cubit.dart';
import 'package:eClassify/features/chat/models/chat_message.dart';
import 'package:eClassify/features/chat/services/chat_event_bus.dart';
import 'package:eClassify/features/notification/cubits/notification_event_cubit.dart';
import 'package:eClassify/features/notification/models/server_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// These listeners emit events to ChatEventBus to sync data across different
// screens and cubits.
class ChatListenersScope extends StatelessWidget {
  const ChatListenersScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final chatSession = context.read<ChatSessionCubit>().state;
    final chat = chatSession.chat;
    return MultiBlocListener(
      listeners: [
        BlocListener<NotificationEventCubit, NotificationEventState>(
          listener: (context, state) {
            if (state case ForegroundNotificationReceived(
              notification: ChatNotification notification,
            )) {
              final payload = state.remoteMessage?.data;
              if (payload == null) return;

              if (notification.chatUser.id == chat.id) {
                final message = ChatMessageFactory.fromNotification(payload);
                context.read<ChatMessageCubit>().addIncomingMessage(message);
                if (message case final OfferChatMessage m) {
                  context.read<ChatSessionCubit>().updateOffer(m.amount);
                }
              }
            }
          },
        ),

        BlocListener<UserBlockCubit, UserBlockState>(
          listener: (context, state) {
            if (state is UserBlockLoading) {
              LoadingOverlay.show(context);
            }
            if (state is UserBlockFailure) {
              LoadingOverlay.hide();
              Log.error(state.message, null, null);
            }
            if (state is UserBlockSuccess) {
              LoadingOverlay.hide();
              final label = state.isBlocked
                  ? 'userBlockedSuccessfully'
                  : 'userUnblockedSuccessfully';
              HelperUtils.showSnackBarMessage(
                context,
                label.translate(context),
              );
              ChatEventBus.instance.emit(
                ChatBlockedEvent(
                  userId: state.userId,
                  isBlockedByMe: state.isBlocked,
                ),
              );
            }
          },
        ),
        BlocListener<ChatMessageCubit, ChatMessageState>(
          listener: (context, state) {
            // TODO(I): Refactor this to avoid using magic strings
            if (state.error != null &&
                state.error.toString() == 'blocked_by_other_user') {
              final session = context.read<ChatSessionCubit>().state;
              ChatEventBus.instance.emit(
                ChatBlockedEvent(
                  userId: session.isCurrentUserSeller
                      ? session.chat.buyerId
                      : session.chat.sellerId,
                  isBlockedByOther: true,
                ),
              );
            }
          },
        ),
        BlocListener<DeleteChatCubit, DeleteChatState>(
          listener: (context, state) {
            if (state is DeleteChatInProgress) {
              LoadingOverlay.show(context);
            } else if (state is DeleteChatFailure) {
              LoadingOverlay.hide();
              HelperUtils.showSnackBarMessage(context, state.error);
            } else if (state is DeleteChatSuccess) {
              LoadingOverlay.hide();
              final chatSession = context.read<ChatSessionCubit>().state;
              ChatEventBus.instance.emit(
                ChatDeletedEvent(
                  itemOfferIds: state.itemOfferIds,
                  itemId: chatSession.chat.itemId,
                ),
              );
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          },
        ),
      ],
      child: child,
    );
  }
}
