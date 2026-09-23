import 'dart:ui';

import 'package:lottie/lottie.dart';

class LottieAssets {
  static const _base = 'assets/lottie';

  static const String loading = '$_base/loading.json';
  static const String success = '$_base/success.json';
  static const String maintenance = '$_base/maintenance.json';
  static const String inlineLoader = '$_base/inline_loader.json';
}

class LottieUtility {
  static LottieDelegates getLoadingIndicatorDelegates({Color? color}) =>
      LottieDelegates(
        values: [
          ValueDelegate.strokeColor(const ['**', 'Stroke 1'], value: color),
          ValueDelegate.color(const ['**', 'Fill 1'], value: color),
        ],
      );

  static LottieDelegates getMaintenanceDelegates({Color? color}) =>
      LottieDelegates(
        values: [
          ValueDelegate.color(const ['**', 'Fill', '**'], value: color),
        ],
      );

  static LottieDelegates getSuccessDelegates({Color? color}) => LottieDelegates(
    values: [
      ValueDelegate.color(const [
        '**',
        'Shape/Shape Outlines',
        '**',
      ], value: color),
    ],
  );

  static LottieDelegates getInlineLoaderDelegates({Color? color}) =>
      LottieDelegates(
        values: [
          ValueDelegate.color(const ['**', 'Fill 1'], value: color),
        ],
      );
}
