import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Apply color to the full svg image
class SvgColorMapper extends ColorMapper {
  const SvgColorMapper({this.color}) : _replaceOnlyPrimary = false;

  const SvgColorMapper.primary({this.color}) : _replaceOnlyPrimary = true;

  final Color? color;
  final bool _replaceOnlyPrimary;

  // DO NOT CHANGE THIS COLOR
  static const _primaryColor = Color(0xff00b2ca);

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (_replaceOnlyPrimary) {
      if (color.toARGB32() == _primaryColor.toARGB32()) {
        return this.color ?? ThemeColors.primaryColor;
      }
      return color;
    }
    return this.color ?? ThemeColors.primaryColor;
  }
}
