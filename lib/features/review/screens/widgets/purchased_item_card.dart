import 'package:eClassify/features/review/cubits/purchased_items_cubit.dart';
import 'package:eClassify/features/review/models/purchased_item.dart';
import 'package:eClassify/features/review/screens/widgets/rating_dialog.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/text/expandable_text.dart';
import 'package:eClassify/features/review/screens/widgets/rating_bar.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

class PurchasedItemCard extends StatelessWidget {
  const PurchasedItemCard({required this.item, super.key});

  final PurchasedItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (item.hasReviewed) return;

        final review = await RatingDialog.show(context, itemId: item.item.id);

        if (review != null) {
          context.read<PurchasedItemsCubit>().addReview(
            itemId: item.item.id,
            review: review,
          );
        }
      },
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomImage(
                src: item.item.image,
                size: Size.square(50),
                radius: 12,
              ),
              16.hGap,
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 4,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.item.name,
                            style: context.titleMedium,
                          ),
                        ),
                        if (item.review?.reviewDate != null)
                          Text(
                            timeago.format(
                              item.review!.reviewDate!,
                              locale: AppSession.currentLocaleShort,
                            ),
                            style: context.labelSmall.muted(context),
                          ),
                      ],
                    ),
                    if (item.hasReviewed) ...[
                      RatingBar(
                        initialRating: item.review!.rating,
                        defaultIconSize: 14,
                      ),
                      if ((item.review?.review).isNotNullAndNotEmpty)
                        ExpandableText(
                          text: item.review!.review!,
                          maxLines: 3,
                          style: context.bodySmall,
                        ),
                    ] else ...[
                      Text(
                        'noReviewYet'.translate(context),
                        style: context.bodySmall.muted(context),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
