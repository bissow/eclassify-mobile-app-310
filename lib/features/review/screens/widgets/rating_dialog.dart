import 'package:eClassify/features/review/cubits/add_item_review_cubit.dart';
import 'package:eClassify/features/review/models/review.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/features/review/screens/widgets/rating_bar.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({required this.itemId, super.key});

  final int itemId;

  static Future<Review?> show(
    BuildContext context, {
    required int itemId,
  }) async {
    return showDialog<Review>(
      context: context,
      barrierDismissible: true,
      builder: (_) => BlocProvider(
        create: (_) => AddItemReviewCubit(),
        child: RatingDialog(itemId: itemId),
      ),
    );
  }

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  final ValueNotifier<bool> _isValid = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _feedbackController.dispose();
    _isValid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: Center(
        child: Text(
          'rateSeller'.translate(context),
          style: TextStyle(
            color: context.colorScheme.onSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'rateYourExperience'.translate(context),
              style: TextStyle(color: context.colorScheme.onTertiaryContainer),
            ),
            10.vGap,
            RatingBar(
              defaultIconSize: 40,
              count: 5,
              mainAxisAlignment: MainAxisAlignment.center,
              onChanged: (value) {
                _rating = value;
              },
            ),
            2.vGap,
            ValueListenableBuilder(
              valueListenable: _isValid,
              builder: (context, value, child) {
                return value
                    ? const SizedBox.shrink()
                    : Text(
                        'ratingCannotBeZero'.translate(context),
                        style: context.labelSmall.withColor(
                          StatusColors.errorMessageColor,
                        ),
                      );
              },
            ),
            16.vGap,
            TextField(
              controller: _feedbackController,
              cursorColor: context.colorScheme.primary,
              decoration: InputDecoration(
                hintText: 'shareYourExperience'.translate(context),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        Expanded(
          child: AppButton(
            variant: AppButtonVariant.text,
            size: AppButtonSize.small,
            title: 'cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Expanded(
          child: BlocListener<AddItemReviewCubit, AddItemReviewState>(
            listener: (context, state) {
              if (state is AddItemReviewSuccess) {
                Navigator.of(context).pop(state.review);
              }
              if (state is AddItemReviewFailure) {
                HelperUtils.showSnackBarMessage(
                  context,
                  state.error.toString(),
                );
              }
            },
            child: AppButton(
              variant: AppButtonVariant.filled,
              size: AppButtonSize.small,
              onPressed: () async {
                if (_rating == 0) {
                  _isValid.value = false;
                  return;
                }
                await context.read<AddItemReviewCubit>().addItemReview(
                  itemId: widget.itemId,
                  rating: _rating,
                  comment: _feedbackController.text.trim(),
                );
              },
              child: BlocBuilder<AddItemReviewCubit, AddItemReviewState>(
                builder: (context, state) {
                  if (state is AddItemReviewInProgress) {
                    return LoadingIndicator.inlineDots();
                  }
                  return Text("submit".translate(context));
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
