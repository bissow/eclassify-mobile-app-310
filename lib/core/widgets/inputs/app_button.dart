import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { filled, elevated, outlined, text }

enum AppButtonSize {
  normal(48, const EdgeInsets.all(12)),
  small(40, EdgeInsets.all(8)),
  compact(32, EdgeInsets.symmetric(horizontal: 8, vertical: 4));

  const AppButtonSize(this.height, this.padding);

  final double height;
  final EdgeInsetsGeometry padding;
}

enum AppButtonWidth { content, expand }

/// Shared button used across the app instead of raw [FilledButton] /
/// [ElevatedButton] / [OutlinedButton] / [TextButton].
///
/// Use the named params ([foregroundColor], [backgroundColor], [shape],
/// [textStyle]) for the common one-off overrides — they're cheap and
/// explicit. Reach for [style] only when a button needs something none of
/// the named params cover (custom [ButtonStyle.minimumSize]/height,
/// [ButtonStyle.padding], [ButtonStyle.overlayColor],
/// [ButtonStyle.visualDensity], [ButtonStyle.tapTargetSize],
/// [ButtonStyle.side], etc). Any property [style] sets wins over the
/// button's computed defaults (including [size]/[width]'s minimumSize).
class AppButton extends StatelessWidget {
  const AppButton({
    required this.variant,
    required this.onPressed,
    this.title,
    this.child,
    this.size = AppButtonSize.normal,
    this.width = AppButtonWidth.expand,
    this.icon,
    this.shape,
    this.foregroundColor,
    this.backgroundColor,
    this.textStyle,
    this.style,
    super.key,
  }) : assert(
         (title == null) != (child == null),
         'AppButton requires exactly one of title or child',
       );

  final String? title;
  final Widget? child;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final AppButtonWidth width;
  final Widget? icon;
  final OutlinedBorder? shape;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  /// Escape hatch for one-off overrides not covered by the params above
  /// (custom height/minimumSize, padding, overlayColor, visualDensity,
  /// tapTargetSize, side, ...). Merged on top of the button's computed
  /// style, so anything set here wins.
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final minimumSize = Size(
      width == AppButtonWidth.expand ? double.maxFinite : 0,
      size.height,
    );

    final label = child ?? Text(title!.translate(context));
    final content = icon == null
        ? label
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [icon!, const SizedBox(width: 8), label],
          );

    ButtonStyle resolveStyle(ButtonStyle base) => style?.merge(base) ?? base;

    return switch (variant) {
      AppButtonVariant.filled => FilledButton(
        onPressed: onPressed,
        style: resolveStyle(
          FilledButton.styleFrom(
            minimumSize: minimumSize,
            shape: shape,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            padding: size.padding,
            textStyle: textStyle,
          ),
        ),
        child: content,
      ),
      AppButtonVariant.elevated => ElevatedButton(
        onPressed: onPressed,
        style: resolveStyle(
          ElevatedButton.styleFrom(
            minimumSize: minimumSize,
            shape: shape,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            padding: size.padding,
            textStyle: textStyle,
          ),
        ),
        child: content,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: onPressed,
        style: resolveStyle(
          OutlinedButton.styleFrom(
            minimumSize: minimumSize,
            shape: shape,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            side: foregroundColor == null
                ? null
                : BorderSide(color: foregroundColor!),
            padding: size.padding,
            textStyle: textStyle,
          ),
        ),
        child: content,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: onPressed,
        style: resolveStyle(
          TextButton.styleFrom(
            minimumSize: minimumSize,
            shape: shape,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            padding: size.padding,
            textStyle: textStyle,
          ),
        ),
        child: content,
      ),
    };
  }
}
