import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/utils/lottie_utility.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum LoaderType { spinner, inlineDots }

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    this.dimension,
    this.color,
    this.type = LoaderType.spinner,
    super.key,
  });

  const LoadingIndicator.spinner({this.dimension, this.color, super.key})
    : type = LoaderType.spinner;

  const LoadingIndicator.inlineDots({this.dimension, this.color, super.key})
    : type = LoaderType.inlineDots;

  final double? dimension;
  final Color? color;
  final LoaderType type;

  @override
  Widget build(BuildContext context) {
    if (!Constant.useLottieProgress) {
      return CircularProgressIndicator(
        color: color ?? context.colorScheme.primary,
      );
    }

    switch (type) {
      case LoaderType.inlineDots:
        return Lottie.asset(
          LottieAssets.inlineLoader,
          width: dimension ?? 48,
          height: dimension ?? 16,
          delegates: LottieUtility.getInlineLoaderDelegates(
            color: color ?? context.colorScheme.onPrimary,
          ),
        );
      case LoaderType.spinner:
        return Lottie.asset(
          LottieAssets.loading,
          width: dimension ?? 70,
          height: dimension ?? 70,
          delegates: LottieUtility.getLoadingIndicatorDelegates(
            color: color ?? context.colorScheme.primary,
          ),
        );
    }
  }
}
