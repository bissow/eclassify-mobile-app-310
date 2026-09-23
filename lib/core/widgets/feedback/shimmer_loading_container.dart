// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

@Deprecated('Use Shimmer widget suite instead')
class CustomShimmer extends StatelessWidget {
  final double? height;
  final double? width;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;

  const CustomShimmer({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
    this.margin,
  });

  static Color baseColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const Color.fromARGB(255, 225, 225, 225)
      : const Color.fromARGB(255, 150, 150, 150);

  static Color highlightColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? Colors.grey.shade100
      : Colors.grey.shade300;

  static Color contentColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? Colors.white.withValues(alpha: 0.85)
      : Colors.white.withValues(alpha: 0.7);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor(context),
      highlightColor: highlightColor(context),
      child: Container(
        width: width,
        margin: margin,
        height: height ?? 10,
        decoration: BoxDecoration(
          color: contentColor(context),
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
        ),
      ),
    );
  }
}
