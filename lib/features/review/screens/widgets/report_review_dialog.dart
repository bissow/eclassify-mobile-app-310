import 'package:eClassify/features/review/cubits/report_review_cubit.dart';
import 'package:eClassify/features/review/cubits/reviews_cubit.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/inputs/custom_text_field.dart';
import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ReportReviewDialog {
  static Future<void> show(BuildContext context, {required int reviewId}) {
    return showDialog<void>(
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<MyReviewsCubit>()),
          BlocProvider(create: (_) => ReportReviewCubit()),
        ],
        child: _ReportReviewForm(reviewId: reviewId),
      ),
    );
  }
}

class _ReportReviewForm extends StatefulWidget {
  const _ReportReviewForm({required this.reviewId});

  final int reviewId;

  @override
  State<_ReportReviewForm> createState() => _ReportReviewFormState();
}

class _ReportReviewFormState extends State<_ReportReviewForm> {
  final _controller = TextController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_controller.validate()) return;
    context.read<ReportReviewCubit>().reportReview(
      reviewId: widget.reviewId,
      reason: _controller.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportReviewCubit, ReportReviewState>(
      listener: (context, state) {
        if (state is ReportReviewSuccess) {
          context.read<MyReviewsCubit>().markReported(
            state.reviewId,
            state.reason,
          );
          Navigator.of(context).pop();
          HelperUtils.showSnackBarMessage(
            context,
            'reviewReportedSuccessfully'.translate(context),
          );
        }
        if (state is ReportReviewFailure) {
          Navigator.of(context).pop();
          HelperUtils.showSnackBarMessage(context, state.error.toString());
        }
      },
      child: AppDialog(
        title: Text(
          'reportReview'.translate(context),
          style: context.titleLarge.bold,
        ),
        content: CustomTextField(
          controller: _controller,
          autofocus: true,
          hintKey: 'writeReasonHere',
          minLines: 3,
          maxLines: 3,
          textAlignVertical: TextAlignVertical.top,
          validators: [EmptyFieldValidator()],
        ),
        actions: [
          Expanded(
            child: AppButton(
              variant: AppButtonVariant.filled,
              size: AppButtonSize.small,
              backgroundColor: context.colorScheme.surface,
              foregroundColor: context.colorScheme.onSurface,
              onPressed: () => Navigator.of(context).pop(),
              child: Text('cancel'.translate(context)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppButton(
              variant: AppButtonVariant.filled,
              size: AppButtonSize.small,
              onPressed: _submit,
              child: BlocBuilder<ReportReviewCubit, ReportReviewState>(
                builder: (context, state) {
                  return state is ReportReviewInProgress
                      ? LoadingIndicator.inlineDots()
                      : Text('submit'.translate(context));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
