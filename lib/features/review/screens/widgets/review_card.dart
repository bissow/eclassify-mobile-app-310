import 'package:eClassify/features/review/models/review.dart';
import 'package:eClassify/features/review/screens/widgets/report_review_dialog.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/widgets/text/expandable_text.dart';
import 'package:eClassify/core/widgets/images/profile_avatar.dart';
import 'package:eClassify/features/review/screens/widgets/rating_bar.dart';
import 'package:eClassify/core/widgets/images/user_placeholder_image.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReviewCard extends StatelessWidget {
  const ReviewCard({required this.review, super.key});

  final Review review;

  /// Only a seller's own received review can be reported, and only once.
  bool get _canReport =>
      review is MyReview && !(review as MyReview).hasReported;

  String? get _reportReason =>
      review is MyReview ? (review as MyReview).reportReason : null;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            ProfileAvatar(
              src: review.buyer?.profile,
              tag: review.id.toString(),
              size: Size.square(40),
              errorImage: UserPlaceholderImage(
                placeholder: review.buyer?.placeholder,
                size: Size.square(40),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if ((review.buyer?.name).isNotNullAndNotEmpty)
                        Expanded(
                          child: Text(
                            review.buyer!.name,
                            style: context.titleMedium,
                          ),
                        ),
                      if (review.reviewDate != null)
                        Text(
                          timeago.format(
                            review.reviewDate!,
                            locale: AppSession.currentLocaleShort,
                          ),
                          style: context.bodySmall.muted(context),
                        ),
                      if (_canReport)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8),
                          child: InkWell(
                            onTap: () => ReportReviewDialog.show(
                              context,
                              reviewId: review.id,
                            ),
                            child: Icon(AppIcons.warningOctagon, size: 20),
                          ),
                        ),
                    ],
                  ),
                  4.vGap,
                  RatingBar(initialRating: review.rating, defaultIconSize: 12),
                  6.vGap,
                  if (review.review.isNotNullAndNotEmpty)
                    ExpandableText(
                      text: review.review!,
                      maxLines: 2,
                      style: context.bodySmall,
                    ),
                  if (_reportReason.isNotNullAndNotEmpty) ...[
                    const Divider(),
                    Text(
                      '${'reportReason'.translate(context)}: $_reportReason',
                      style: context.bodySmall.muted(context),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
