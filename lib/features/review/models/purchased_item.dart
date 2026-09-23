import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/review/models/review.dart';
import 'package:eClassify/core/models/user_preview.dart';
import 'package:eClassify/core/utils/json_helper.dart';

class PurchasedItem {
  PurchasedItem({
    required this.item,
    required this.review,
    required this.hasReviewed,
    this.user,
  });

  PurchasedItem.fromJson(Json json)
    : item = ItemPreview.fromJson(json),
      review = JsonHelper.parseObjectOrNull(
        json['review'] as Json?,
        Review.fromJson,
      ),
      user = JsonHelper.parseObjectOrNull(
        json['user'] as Json?,
        UserPreview.fromJson,
      ),
      hasReviewed = json['is_already_reviewed'] as bool? ?? false;

  final ItemPreview item;
  final Review? review;
  final UserPreview? user;
  final bool hasReviewed;

  PurchasedItem copyWith({required Review review}) =>
      PurchasedItem(item: item, review: review, hasReviewed: true);
}
