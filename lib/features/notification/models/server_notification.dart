import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/features/chat/models/chat.dart';
import 'package:eClassify/features/chat/models/item_offer.dart';
import 'package:eClassify/features/notification/enums/notification_type.dart';

/// Typed representation of a push notification payload — one variant per
/// [NotificationType]. Replaces raw `Map<String, dynamic>` reads scattered
/// across notification handling with a single parse site.
sealed class ServerNotification {
  const ServerNotification();

  /// Parses [data] according to [type]. Any parse failure — a missing or
  /// malformed required field — collapses to [UnknownNotification] instead
  /// of throwing, so a malformed payload degrades to a no-op rather than
  /// crashing whichever listener is reacting to it.
  ///
  /// Callers must ensure [AppSession.isAuthenticated] when [type]
  /// requires it (see [NotificationType.requiresAuth]) — this factory
  /// assumes that check already happened.
  factory ServerNotification.fromData(
    NotificationType type,
    Map<String, dynamic> data, {
    String? preview,
  }) {
    try {
      return switch (type) {
        NotificationType.chat => ChatNotification.parse(data, preview: preview),
        NotificationType.offer => OfferNotification.parse(data),
        NotificationType.itemUpdate => ItemUpdateNotification.parse(data),
        NotificationType.itemEdit => ItemEditNotification.parse(data),
        NotificationType.jobApplication => JobApplicationNotification.parse(
          data,
        ),
        NotificationType.applicationStatus =>
          const ApplicationStatusNotification(),
        NotificationType.payment => const PaymentNotification(),
        NotificationType.verificationStatus =>
          const VerificationStatusNotification(),
        NotificationType.itemReview => const ItemReviewNotification(),
        NotificationType.blog => BlogNotification.parse(data),
        NotificationType.notification => _parseGenericNotification(data),
        NotificationType.unknown => UnknownNotification(data),
      };
    } catch (_) {
      return UnknownNotification(data);
    }
  }

  /// [NotificationType.notification] is a fork: an attached item opens a
  /// public ad-details screen (no session needed), while the fallback
  /// opens the user's own notification list (session needed). Unlike
  /// chat/offer, neither branch needs [AppSession.currentUser] to *parse*,
  /// so this type is safe to parse unauthenticated — the auth check for
  /// [GenericNotification] happens in the handler, at the point it
  /// navigates, not upstream in the cubit.
  static ServerNotification _parseGenericNotification(
    Map<String, dynamic> data,
  ) {
    final rawItemId = data['item_id'];
    final itemId = (rawItemId != null && rawItemId != '')
        ? int.tryParse(rawItemId.toString())
        : null;

    if (itemId != null) return ItemNotification(itemId: itemId);
    return GenericNotification(notificationId: data['notification_id'] as int?);
  }
}

final class ChatNotification extends ServerNotification {
  const ChatNotification({
    required this.chatUser,
    required this.itemOffer,
    required this.message,
    required this.time,
    required this.isReceiverSeller,
    this.offerAmount,
    this.preview,
  });

  final Chat chatUser;

  /// Only present when [isReceiverSeller] — a buyer's message on an item
  /// offer also needs to be surfaced as an offer update to the seller.
  final ItemOffer? itemOffer;
  final String message;
  final DateTime time;

  /// Whether *this device's user* (the notification recipient) is the
  /// seller side of the chat. The payload's `user_type` field describes
  /// the *sender*, not the recipient, so this is the inverse: a message
  /// sent by a buyer (`user_type == 'buyer'`) means the recipient — us —
  /// must be the seller. Drives whether an [itemOffer] update is also
  /// emitted, which navigation route/args `NotificationHandler` builds
  /// (`is_seller` argument to `Routes.chatScreen`), and whether the
  /// seller's offer-unread-count should be cleared on tap.
  final bool isReceiverSeller;

  /// Formatted amount when the message type is ChatMessageType.offer
  final String? offerAmount;

  /// Server-built one-line preview of the message (the push body), set
  /// for every type — text, offer, image, audio, file. Preferred over
  /// [message] for the inbox row.
  final String? preview;

  static ChatNotification parse(Map<String, dynamic> data, {String? preview}) {
    final isReceiverSeller =
        data['user_type'].toString().toLowerCase() == 'buyer';

    return ChatNotification(
      chatUser: Chat.fromNotification(data, myId: AppSession.currentUser!.id),
      itemOffer: isReceiverSeller ? _tryParseItemOffer(data) : null,
      message: data['message'] as String? ?? '',
      time:
          DateTime.tryParse(data['updated_at'] as String? ?? '') ??
          DateTime.now(),
      isReceiverSeller: isReceiverSeller,
      offerAmount: data['item_formatted_amount'] as String?,
      // Data-only pushes have no notification block; the same preview is
      // also sent as `body` in the data map.
      preview: preview ?? data['body'] as String?,
    );
  }

  static ItemOffer? _tryParseItemOffer(Map<String, dynamic> data) {
    try {
      return JsonHelper.parseObjectOrNull(data, ItemOffer.fromNotification);
    } catch (_) {
      return null;
    }
  }
}

final class OfferNotification extends ServerNotification {
  const OfferNotification({required this.itemOffer});

  final ItemOffer itemOffer;

  static OfferNotification parse(Map<String, dynamic> data) {
    return OfferNotification(itemOffer: ItemOffer.fromNotification(data));
  }
}

final class ItemUpdateNotification extends ServerNotification {
  const ItemUpdateNotification({this.status});

  /// The item's new status (e.g. `active`, `expired`) — used by
  /// screen-local listeners like `MyItemsTab` to decide whether to refresh.
  final String? status;

  static ItemUpdateNotification parse(Map<String, dynamic> data) {
    return ItemUpdateNotification(status: data['status']?.toString());
  }
}

final class ItemEditNotification extends ServerNotification {
  const ItemEditNotification({required this.itemId});

  final int itemId;

  static ItemEditNotification parse(Map<String, dynamic> data) {
    final itemId = int.parse(data['item_id'].toString());
    return ItemEditNotification(itemId: itemId);
  }
}

final class JobApplicationNotification extends ServerNotification {
  const JobApplicationNotification({required this.itemId});

  final int itemId;

  static JobApplicationNotification parse(Map<String, dynamic> data) {
    final itemId = int.tryParse(data['item_id']?.toString() ?? '') ?? 0;
    return JobApplicationNotification(itemId: itemId);
  }
}

final class ApplicationStatusNotification extends ServerNotification {
  const ApplicationStatusNotification();
}

final class PaymentNotification extends ServerNotification {
  const PaymentNotification();
}

final class VerificationStatusNotification extends ServerNotification {
  const VerificationStatusNotification();
}

final class ItemReviewNotification extends ServerNotification {
  const ItemReviewNotification();
}

final class BlogNotification extends ServerNotification {
  const BlogNotification({required this.blogId});

  final int blogId;

  static BlogNotification parse(Map<String, dynamic> data) {
    final blogId = int.parse(data['blog_id'].toString());
    return BlogNotification(blogId: blogId);
  }
}

/// [NotificationType.notification] with an item attached — opens the ad
/// details screen, same as [ItemEditNotification]. Doesn't require a
/// session: browsing an ad is public.
final class ItemNotification extends ServerNotification {
  const ItemNotification({required this.itemId});

  final int itemId;
}

/// [NotificationType.notification] with no item attached — falls back to
/// the user's own notification list, which does require a session. The
/// handler must check [AppSession.isAuthenticated] before navigating,
/// since this type isn't gated upstream (see [ServerNotification.fromData]
/// and [ServerNotification._parseGenericNotification]).
final class GenericNotification extends ServerNotification {
  const GenericNotification({this.notificationId});

  final int? notificationId;
}

/// Unrecognized type, or a payload that failed to parse for its type.
final class UnknownNotification extends ServerNotification {
  const UnknownNotification(this.raw);

  final Map<String, dynamic> raw;
}
