import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/features/review/models/review.dart';
import 'package:eClassify/features/review/models/review_summary.dart';
import 'package:eClassify/features/seller/models/seller.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/utils/log.dart';

class ReviewRepository {
  ReviewRepository._internal();

  static final ReviewRepository _instance = ReviewRepository._internal();

  static ReviewRepository get instance => _instance;

  Future<Review> reviewItem({
    required int itemId,
    required int rating,
    required String review,
  }) async {
    try {
      final response = await Api.post(
        url: ApiEndpoints.addItemReview,
        parameter: {
          ApiParams.itemId: itemId,
          ApiParams.ratings: rating,
          ApiParams.review: review,
        },
      );

      return Review.fromJson(response['data'] as Json);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<void> reportReview({
    required int reviewId,
    required String reason,
  }) async {
    try {
      await Api.post(
        url: ApiEndpoints.addReviewReport,
        parameter: {
          ApiParams.sellerReviewId: reviewId,
          ApiParams.reportReason: reason,
        },
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<PaginatedResult<T>> _getReviews<T extends Review>({
    required FromJson<T> parser,
    int page = 1,
    int? sellerId,
  }) async {
    try {
      final isForSeller = sellerId != null;
      final url = isForSeller ? ApiEndpoints.getSeller : ApiEndpoints.getMyReview;
      final response = await Api.get(
        url: url,
        queryParameters: {ApiParams.page: page, ApiParams.id: ?sellerId},
      );

      final reviews = JsonHelper.parseList<T>(
        response['data']['ratings']['data'] as List?,
        parser,
      );
      final total = response['data']['ratings']['total'] as int;
      final averageRating = isForSeller
          ? response['data']['seller']['average_rating'] as num?
          : response['data']['average_rating'] as num?;
      final ratingsCount = (response['data']['ratings_count'] as Map?)
          ?.cast<String, int>();

      var metadata;
      if (isForSeller) {
        metadata = SellerReviewSummary(
          averageRating: averageRating ?? 0,
          ratingsCount: ratingsCount ?? {},
          seller: Seller.fromJson(response['data']['seller'] as Json),
        );
      } else {
        metadata = ReviewSummary(
          averageRating: averageRating ?? 0,
          ratingsCount: ratingsCount ?? {},
        );
      }

      return PaginatedResult<T>(
        data: reviews,
        total: total,
        metadata: metadata,
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<PaginatedResult<MyReview>> getMyReviews({int page = 1}) async {
    return await _getReviews<MyReview>(parser: MyReview.fromJson, page: page);
  }

  Future<PaginatedResult<SellerReview>> getSellerReviews({
    int page = 1,
    required int sellerId,
  }) async {
    return await _getReviews<SellerReview>(
      parser: SellerReview.fromJson,
      page: page,
      sellerId: sellerId,
    );
  }
}
