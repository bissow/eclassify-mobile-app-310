import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/cubits/bottom_nav_cubit.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/chat/cubits/seller_item_offers_cubit.dart';
import 'package:eClassify/features/chat/models/chat.dart';
import 'package:eClassify/features/chat/services/chat_event_bus.dart';
import 'package:eClassify/features/notification/models/server_notification.dart';
import 'package:eClassify/features/verification/cubits/verification_request_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class NotificationHandler {
  /// Global side effects — state that must update regardless of which
  /// screen is currently mounted (unread counts, offer lists, ...).
  /// Screen-local reactions belong in `ServerNotificationListener` instead.
  static void handleSideEffects(
    BuildContext context,
    ServerNotification notification,
  ) {
    if (!context.mounted) return;

    switch (notification) {
      case VerificationStatusNotification():
        context.read<VerificationRequestCubit>().fetchVerificationRequest();

      case ChatNotification():
        final offerId = notification.chatUser.id;
        final isCurrentChat = AppSession.activeChatId == offerId;

        final chatMessage = ChatNotificationMessage(
          id: offerId,
          itemId: notification.chatUser.itemId,
          message: notification.message,
          time: notification.time,
          unreadCount: isCurrentChat ? 0 : 1,
          offerAmount: notification.offerAmount,
          preview: notification.preview,
        );

        if (notification.isReceiverSeller && notification.itemOffer != null) {
          ChatEventBus.instance.emit(
            ChatMessageReceivedEvent(
              message: chatMessage,
              itemOffer: notification.itemOffer,
              chatUser: notification.chatUser,
              isReceiverSeller: true,
            ),
          );
        } else {
          ChatEventBus.instance.emit(
            ChatMessageReceivedEvent(
              message: chatMessage,
              chatUser: notification.chatUser,
              isReceiverSeller: false,
            ),
          );
        }

      case OfferNotification():
        context.read<SellerItemOffersCubit>().addOffer(notification.itemOffer);

      case ItemUpdateNotification():
      case ItemEditNotification():
      case JobApplicationNotification():
      case ApplicationStatusNotification():
      case PaymentNotification():
      case ItemReviewNotification():
      case BlogNotification():
      case ItemNotification():
      case GenericNotification():
      case UnknownNotification():
        break;
    }
  }

  /// Navigation triggered by the user tapping a notification.
  static void handleNotification(
    BuildContext context,
    ServerNotification notification,
  ) {
    if (!context.mounted) return;

    Log.info('Handling Notification $notification');

    switch (notification) {
      case ChatNotification():
        final itemOfferId = notification.chatUser.id;
        final isCurrentChat = AppSession.activeChatId == itemOfferId;

        // Handles: user already on the chat page and receives new messages
        // and taps the notification — without this, it opens a new window
        // on top of the current one.
        //
        // Note: This bug is only present on iOS right now. On Android, the
        // notification will not be shown when the chat is open.
        if (isCurrentChat) {
          ChatEventBus.instance.emit(
            ChatReadEvent(itemOfferId, itemId: notification.chatUser.itemId),
          );
          return;
        }

        // isReceiverSeller already means "this device's user is the
        // seller" — see its doc comment in server_notification.dart.
        final isSeller = notification.isReceiverSeller;
        if (isSeller) {
          context.read<SellerItemOffersCubit>().clearOfferUnreadCount(
            notification.chatUser.itemId,
          );
        }

        Navigator.of(context).pushNamed(
          Routes.chatScreen,
          arguments: {
            'chat_user': notification.chatUser,
            'is_seller': isSeller,
          },
        );

      case OfferNotification():
        Navigator.of(context).pushNamed(
          Routes.sellerItemChatScreen,
          arguments: {
            'item_id': notification.itemOffer.id,
            'item_offer_id': notification.itemOffer.users.first.offerId,
          },
        );

      case ItemUpdateNotification():
        Navigator.pushNamed(context, Routes.myItemScreen);

      case ItemEditNotification():
        Navigator.pushNamed(
          context,
          Routes.adDetailsScreen,
          arguments: {'item_id': notification.itemId},
        );

      case JobApplicationNotification():
        Future.delayed(Duration.zero, () {
          if (!context.mounted) return;
          Navigator.pushNamed(
            context,
            Routes.jobApplicationList,
            arguments: {'itemId': notification.itemId},
          );
        });

      case ApplicationStatusNotification():
        Navigator.pushNamed(
          context,
          Routes.jobApplicationList,
          arguments: {'isMyJobApplications': true},
        );

      case PaymentNotification():
        Navigator.pushNamed(context, Routes.activePlanScreen);

      case VerificationStatusNotification():
        context.read<BottomNavCubit>().changeTab(BottomTab.profile);

      case ItemReviewNotification():
        context.read<BottomNavCubit>().changeTab(BottomTab.profile);
        Navigator.pushNamed(context, Routes.reviewScreen);

      case BlogNotification():
        Navigator.pushNamed(
          context,
          Routes.blogsScreen,
          arguments: notification.blogId,
        );

      case ItemNotification():
        Navigator.pushNamed(
          context,
          Routes.adDetailsScreen,
          arguments: {'item_id': notification.itemId},
        );

      case GenericNotification():
        // Unlike every other branch here, NotificationType.notification
        // isn't gated by requiresAuth upstream (see enums.dart) since
        // parsing it never touches session state — so this branch, the
        // one that actually needs a session, self-guards here instead.
        if (!AppSession.isAuthenticated) return;
        Navigator.pushNamed(
          context,
          Routes.notificationListScreen,
          arguments: {'notification_id': notification.notificationId},
        );

      case UnknownNotification():
        break;
    }
  }
}
