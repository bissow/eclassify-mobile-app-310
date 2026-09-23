import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/features/ad_posting/cubits/ad_posting_cubit.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdPostingStepWidget extends StatelessWidget {
  const AdPostingStepWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdPostingCubit, AdPostingState>(
      builder: (context, state) {
        final index = state.steps.indexOf(state.activeStep) + 1;
        final total = state.steps.length;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.secondary,
            border: Border(top: BorderSide(color: context.theme.dividerColor)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Constant.horizontalPadding,
              vertical: 16,
            ),
            child: Row(
              spacing: 16,
              children: [
                CircleAvatar(
                  backgroundColor: context.colorScheme.primary.withValues(
                    alpha: .1,
                  ),
                  child: Text(
                    '$index/$total',
                    style: context.titleSmall.withColor(
                      context.colorScheme.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        state.activeStep.title.translate(context),
                        style: context.labelLarge,
                      ),
                      Text(
                        state.activeStep.subtitle.translate(context),
                        style: context.bodySmall.withColor(context.mutedColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
