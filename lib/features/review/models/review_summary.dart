import 'package:collection/collection.dart';
import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/features/seller/models/seller.dart';

final class ReviewSummary extends Metadata {
  ReviewSummary({required this.averageRating, required this.ratingsCount})
    : totalRating = ratingsCount.values.sum;
  final num averageRating;
  final Map<String, int> ratingsCount;
  final int totalRating;
}

final class SellerReviewSummary extends ReviewSummary {
  SellerReviewSummary({
    required super.averageRating,
    required super.ratingsCount,
    required this.seller,
  });

  final Seller seller;

  SellerReviewSummary copyWithSeller(Seller seller) => SellerReviewSummary(
    averageRating: averageRating,
    ratingsCount: ratingsCount,
    seller: seller,
  );
}
