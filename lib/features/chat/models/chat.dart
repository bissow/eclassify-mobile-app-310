import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/models/currency.dart';
import 'package:eClassify/features/chat/models/chat_message.dart';
import 'package:eClassify/core/models/user_preview.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:flutter/foundation.dart';

@immutable
class Chat {
  Chat({
    required this.id,
    required this.sellerId,
    required this.buyerId,
    required this.itemId,
    required this.lastChatMessage,
    required this.unreadCount,
    required this.lastMessageTime,
    required this.formattedAmount,
    required this.seller,
    required this.buyer,
    required this.item,
    this.isUserBlocked = false,
    this.isBlockedByOtherUser = false,
  });

  Chat.fromJson(Json json)
    : id = json['id'] as int,
      sellerId = json['seller_id'] as int,
      buyerId = json['buyer_id'] as int,
      itemId = json['item_id'] as int,
      lastChatMessage = json['last_chat_message'] as String?,
      unreadCount = json['unread_chat_count'] as int? ?? 0,
      lastMessageTime = DateTime.parse(json['last_message_time'] as String),
      formattedAmount = json['formatted_amount'] as String?,
      isUserBlocked = json['user_blocked'] as bool? ?? false,
      isBlockedByOtherUser = json['is_my_user_blocked'] as bool? ?? false,
      seller = UserPreview.fromJson(json['seller'] as Json),
      buyer = UserPreview.fromJson(json['buyer'] as Json),
      item = ChatItem.fromJson(json['item'] as Json);

  final int id;
  final int sellerId;
  final int buyerId;
  final int itemId;
  final String? lastChatMessage;
  final int unreadCount;
  final DateTime lastMessageTime;
  final String? formattedAmount;
  final bool isUserBlocked;
  final bool isBlockedByOtherUser;
  final UserPreview seller;
  final UserPreview buyer;
  final ChatItem item;

  Chat copyWith({
    int? unreadCount,
    String? lastChatMessage,
    DateTime? lastMessageTime,
    bool? isUserBlocked,
    bool? isBlockedByOtherUser,
    String? formattedAmount,
  }) => Chat(
    id: id,
    sellerId: sellerId,
    buyerId: buyerId,
    itemId: itemId,
    lastChatMessage: lastChatMessage ?? this.lastChatMessage,
    unreadCount: unreadCount ?? this.unreadCount,
    lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    formattedAmount: formattedAmount ?? this.formattedAmount,
    isUserBlocked: isUserBlocked ?? this.isUserBlocked,
    isBlockedByOtherUser: isBlockedByOtherUser ?? this.isBlockedByOtherUser,
    seller: seller,
    buyer: buyer,
    item: item,
  );

  Chat fromChatNotification(ChatNotificationMessage message) => this.copyWith(
    unreadCount: unreadCount + message.unreadCount,
    // The push body is the server's per-type preview (offer text, "sent a
    // photo", ...). `message` is empty for non-text types, and copyWith
    // would keep the stale preview if nothing non-null is passed.
    lastChatMessage: message.preview.isNotNullAndNotEmpty
        ? message.preview
        : message.message.isNotNullAndNotEmpty
        ? message.message
        : message.offerAmount,
    lastMessageTime: message.time,
    formattedAmount: message.offerAmount,
  );

  /// Inbox preview for a message this user just sent. Called twice per
  /// send: with the optimistic placeholder (local text as a stand-in) and
  /// again with the server-confirmed message, whose [ChatMessage.preview]
  /// is the wording the inbox would fetch.
  Chat fromSentMessage(ChatMessage message) => this.copyWith(
    lastChatMessage:
        message.preview ??
        switch (message) {
          TextChatMessage(:final message) => message,
          FileAndTextMessage(:final message) => message,
          OfferChatMessage(:final amount) => amount,
          // Media-only placeholder: keep the previous preview until the
          // server's wording arrives.
          _ => null,
        },
    lastMessageTime: message.dateTime,
  );

  static Chat fromNotification(Map<String, dynamic> data, {required int myId}) {
    final bool isSeller =
        data['user_type'].toString().toLowerCase() != 'seller';

    return Chat(
      id: int.parse(data['item_offer_id'].toString()),
      sellerId: isSeller ? myId : int.parse(data['user_id'].toString()),
      buyerId: isSeller ? int.parse(data['user_id'].toString()) : myId,
      itemId: int.parse(data['item_id'].toString()),
      // `message` is empty for offers/media; `body` is the server's
      // per-type preview ("💰 Offered: ₹ 10,000.00"). A chat created from
      // its first offer notification would otherwise land in the inbox
      // with a blank preview.
      lastChatMessage: switch (data['body'] as String?) {
        final body? when body.isNotEmpty => body,
        _ => data['message'] as String?,
      },
      unreadCount: int.parse(data['unread_count'].toString()),
      lastMessageTime:
          DateTime.tryParse(data['updated_at'] as String? ?? '') ??
          DateTime.now(),
      formattedAmount:
          data['item_formatted_amount'] as String? ??
          data['item_offer_amount'] as String?,
      seller: UserPreview(
        id: isSeller ? myId : int.parse(data['user_id'].toString()),
        name: isSeller
            ? data['my_user_name'] as String? ?? ""
            : data['user_name'] as String,
        profile: isSeller
            ? data['my_user_profile'] as String?
            : data['user_profile'] as String?,
      ),
      buyer: UserPreview(
        id: isSeller ? int.parse(data['user_id'].toString()) : myId,
        name: isSeller
            ? data['user_name'] as String
            : data['my_user_name'] as String? ?? "",
        profile: isSeller
            ? data['user_profile'] as String?
            : data['my_user_profile'] as String?,
      ),
      item: ChatItem(
        id: int.parse(data['item_id'].toString()),
        name: data['item_name'] as String,
        image: data['item_image'] as String,
        // `item_price` is the raw number; the app bar shows this string
        // as-is, so prefer the formatted one.
        price:
            data['item_formatted_price'] as String? ??
            data['item_price'] as String?,
      ),
    );
  }
}

class ChatNotificationMessage {
  ChatNotificationMessage({
    required this.id,
    required this.itemId,
    required this.message,
    required this.time,
    required this.unreadCount,
    this.offerAmount,
    this.preview,
  });

  final int id;
  final int itemId;
  final String? message;
  final DateTime? time;
  final int unreadCount;
  final String? offerAmount;

  /// Server-built preview line for the inbox (see ChatNotification.preview).
  final String? preview;
}

class ChatItem {
  ChatItem({
    required this.id,
    required this.name,
    required this.image,
    this.price,
    this.currency,
  }) : isJobItem = false;

  ChatItem.fromJson(Json json)
    : id = json['id'] as int,
      name = json['translation']?['name'] as String,
      image = json['image'] as String,
      price =
          (json['formatted_price'] ?? json['formatted_salary_range'])
              as String?,
      currency = JsonHelper.parseObjectOrNull(
        json['currency'],
        Currency.fromJson,
      ),
      isJobItem = json['formatted_salary_range'] != null;

  final int id;
  final String name;
  final String image;
  final String? price;
  final Currency? currency;
  final bool isJobItem;

  bool get isFree => price == null || price?.toLowerCase() == 'free';
}
