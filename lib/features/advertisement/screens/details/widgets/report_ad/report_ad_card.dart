import 'package:eClassify/features/advertisement/cubits/item_report_cubit.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/report_ad/report_reason_bottom_sheet.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportAdCard extends StatefulWidget {
  const ReportAdCard({
    required this.itemId,
    required this.isReported,
    super.key,
  });

  final int itemId;
  final bool isReported;

  @override
  State<ReportAdCard> createState() => _ReportAdCardState();
}

class _ReportAdCardState extends State<ReportAdCard> {
  late bool isShowing = !widget.isReported;

  @override
  Widget build(BuildContext context) {
    if (!isShowing) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Constant.horizontalPadding,
        vertical: 8,
      ),
      child: BlocListener<ItemReportCubit, ItemReportState>(
        listener: (context, state) {
          if (state is ItemReportSuccess) {
            HelperUtils.showSnackBarMessage(context, state.message);
            setState(() {
              isShowing = false;
            });
          }
          if (state is ItemReportFailure) {
            HelperUtils.showSnackBarMessage(context, state.message);
          }
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: context.colorScheme.onSurface.withValues(alpha: .05),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "didYouFindAnyProblemWithThisItem".translate(context),
                  style: context.bodyLarge,
                ),
                Row(
                  children: [
                    Expanded(child: Text('ID #${widget.itemId}')),
                    AppButton(
                      variant: AppButtonVariant.filled,
                      width: AppButtonWidth.content,
                      size: AppButtonSize.compact,
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red,
                      title: 'reportThisAd',
                      onPressed: () {
                        UiUtils.checkUser(
                          onNotGuest: () {
                            ReportReasonBottomSheet.show(
                              context,
                              itemId: widget.itemId,
                            );
                          },
                          context: context,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
