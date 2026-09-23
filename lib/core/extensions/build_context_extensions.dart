import 'package:eClassify/core/constants/constant.dart';
import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Padding for whatever fills an `AppScaffold` body: page margins, a
  /// fixed gap under the app bar, and the bottom `AppScaffold` reserved
  /// (gap above the action bar, or gap plus system inset). On a scroll view
  /// that bottom is *scroll* padding — content passes under it and rests
  /// clear of it. Pass [top] as 0 when something else already sits between
  /// the app bar and the content. A box that merely hosts a scroll view
  /// uses `Constant.pagePadding` instead and lets the scroll view own the
  /// bottom.
  EdgeInsets bodyPadding({double top = Constant.verticalPadding}) =>
      Constant.pagePadding.copyWith(
        top: top,
        bottom: MediaQuery.paddingOf(this).bottom,
      );

  double get screenHeight => MediaQuery.sizeOf(this).height;

  Size sizeFromAspectRatio(double aspectRatio, {bool considerPadding = true}) {
    final width =
        screenWidth - (considerPadding ? Constant.horizontalPadding * 2 : 0);

    final height = width / aspectRatio;

    return Size(width, height);
  }
}
