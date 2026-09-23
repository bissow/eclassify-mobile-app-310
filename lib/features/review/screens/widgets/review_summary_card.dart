import 'package:eClassify/core/cubits/paginated_cubit.dart';
import 'package:eClassify/features/review/cubits/reviews_cubit.dart';
import 'package:eClassify/features/review/models/review.dart';
import 'package:eClassify/features/review/models/review_summary.dart';
import 'package:eClassify/features/review/screens/widgets/rating_count_bars.dart';
import 'package:eClassify/features/review/screens/widgets/rating_bar.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReviewSummaryCard<C extends ReviewsCubit> extends StatelessWidget {
  const ReviewSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<C>().state;

    if (state is Loading) {
      return AspectRatio(aspectRatio: 3, child: CustomShimmer());
    }
    if (state is DataState<Review>) {
      final summary = state.result.metadata as ReviewSummary;
      return Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            spacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4,
                children: [
                  Text(
                    summary.averageRating.toStringAsFixed(1),
                    style: context.headlineMedium,
                  ),
                  RatingBar(
                    initialRating: summary.averageRating,
                    defaultIconSize: 12,
                  ),
                  Text(
                    '${summary.totalRating.compact} ${'ratings'.translate(context)}',
                    style: context.labelLarge,
                  ),
                ],
              ),
              Expanded(
                child: RatingCountBars(ratingCount: summary.ratingsCount),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
