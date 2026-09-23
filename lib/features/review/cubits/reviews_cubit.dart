import 'package:eClassify/core/cubits/paginated_cubit.dart';
import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/features/review/models/review.dart';
import 'package:eClassify/features/review/models/review_summary.dart';
import 'package:eClassify/features/review/repository/review_repository.dart';

abstract class ReviewsCubit<T extends Review, P> extends PaginatedCubit<T, P> {}

final class MyReviewsCubit extends ReviewsCubit<MyReview, void> {
  MyReviewsCubit() : super();

  @override
  Future<PaginatedResult<MyReview>> getPage(int page, {void params}) async {
    return await ReviewRepository.instance.getMyReviews(page: page);
  }

  /// Marks a review as reported locally so the list reflects the report
  /// without refetching the page.
  void markReported(int reviewId, String reason) {
    if (state is! DataState) return;
    final dataState = state as DataState<MyReview>;
    final reviews = [
      for (final review in dataState.result.data)
        if (review.id == reviewId) review.copyWithReport(reason) else review,
    ];
    emit(
      dataState.toSuccess(
        dataState.result.copyWithData(reviews, null),
        reset: true,
      ),
    );
  }
}

final class SellerReviewsCubit extends ReviewsCubit<SellerReview, int> {
  SellerReviewsCubit() : super();

  @override
  Future<PaginatedResult<SellerReview>> getPage(int page, {int? params}) {
    return ReviewRepository.instance.getSellerReviews(
      page: page,
      sellerId: params!,
    );
  }

  void updateSellerFollowerCount({required bool isFollowing}) {
    if (state is! DataState) return;
    final dataState = state as DataState<SellerReview>;
    final summary = dataState.result.metadataAs<SellerReviewSummary>();
    final seller = summary.seller;
    final newSeller = seller.copyWith(
      followers: isFollowing
          ? (seller.followers ?? 0) + 1
          : (seller.followers ?? 0) - 1,
      isFollowing: isFollowing,
    );
    ;
    final newState = dataState.toSuccess(
      dataState.result.copyWithMetadata(summary.copyWithSeller(newSeller)),
      reset: true,
    );
    emit(newState);
  }
}
