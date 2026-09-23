import 'package:eClassify/features/review/cubits/reviews_cubit.dart';
import 'package:eClassify/features/review/models/review.dart';
import 'package:eClassify/features/review/screens/widgets/review_card.dart';
import 'package:eClassify/features/review/screens/widgets/review_summary_card.dart';
import 'package:eClassify/core/widgets/layout/paginated_view/paginated_view.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';

class MyReviewsList extends StatelessWidget {
  const MyReviewsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Constant.pagePadding.copyWith(top: Constant.verticalPadding),
      child: Column(
        spacing: 12,
        children: [
          const ReviewSummaryCard<MyReviewsCubit>(),
          Expanded(
            child: PaginatedListView<MyReviewsCubit, MyReview, void>(
              padding: context.bodyPadding(top: 0).copyWith(left: 0, right: 0),
              itemBuilder: (context, review) => ReviewCard(review: review),
              separatorBuilder: (_, _) => 8.vGap,
            ),
          ),
        ],
      ),
    );
  }
}
