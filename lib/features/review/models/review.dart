import 'package:eClassify/core/models/user_preview.dart';
import 'package:eClassify/core/utils/json_helper.dart';

base class Review {
  Review._({
    required this.id,
    required this.rating,
    required this.review,
    required this.reviewDate,
    required this.buyer,
  });

  Review.fromJson(Json json)
    : id = json['id'] as int,
      rating = num.tryParse(json['ratings'].toString()) ?? 0,
      review = json['review'] as String?,
      reviewDate = DateTime.tryParse(json['created_at'] as String? ?? ''),
      buyer = JsonHelper.parseObjectOrNull(
        json['buyer'] as Json?,
        UserPreview.fromJson,
      );
  final int id;
  final num rating;
  final String? review;
  final DateTime? reviewDate;
  final UserPreview? buyer;
}

final class SellerReview extends Review {
  SellerReview.fromJson(super.json) : super.fromJson();
}

final class MyReview extends Review {
  MyReview.fromJson(super.json)
    : itemImage = json['item']['image'] as String,
      hasReported = (json['report_status'] as String?) == 'reported',
      reportReason = json['report_reason'] as String?,
      super.fromJson();

  MyReview._({
    required this.itemImage,
    required this.hasReported,
    required this.reportReason,
    required super.id,
    required super.rating,
    required super.review,
    required super.reviewDate,
    required super.buyer,
  }) : super._();

  final String itemImage;
  final bool hasReported;
  final String? reportReason;

  MyReview copyWithReport(String reason) => MyReview._(
    itemImage: itemImage,
    hasReported: true,
    reportReason: reason,
    id: id,
    rating: rating,
    review: review,
    reviewDate: reviewDate,
    buyer: buyer,
  );
}
