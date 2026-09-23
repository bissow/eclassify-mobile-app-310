import 'package:flutter/widgets.dart';

extension ScrollExtension on ScrollNotification {
  bool get isScrollEndNotification => this is ScrollEndNotification;

  bool get isAtBottom =>
      isScrollEndNotification && metrics.pixels >= metrics.maxScrollExtent;

  bool get isNearBottom => metrics.pixels >= metrics.maxScrollExtent - 300;
}
