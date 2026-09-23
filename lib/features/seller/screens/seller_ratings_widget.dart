import 'package:eClassify/features/review/cubits/reviews_cubit.dart';
import 'package:eClassify/features/review/models/review.dart';
import 'package:eClassify/features/review/screens/widgets/review_card.dart';
import 'package:eClassify/features/review/screens/widgets/review_summary_card.dart';
import 'package:eClassify/core/widgets/layout/paginated_view/paginated_view.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:flutter/material.dart';

class SellerRatingsWidget extends StatelessWidget {
  const SellerRatingsWidget({required this.sellerId, super.key});

  final int sellerId;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        const ReviewSummaryCard<SellerReviewsCubit>(),
        Expanded(
          child: PaginatedListView<SellerReviewsCubit, SellerReview, int>(
            autoFetch: false,
            padding: EdgeInsets.zero,
            parameters: sellerId,
            itemBuilder: (context, review) => ReviewCard(review: review),
            separatorBuilder: (_, _) => 8.vGap,
          ),
        ),
      ],
    );
  }
}
