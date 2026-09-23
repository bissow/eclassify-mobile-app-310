import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Renders [template] as rich text, replacing `{tagName}` placeholders with
/// tappable spans. Lets translated strings control where — or whether —
/// each linked phrase appears (not every locale puts "Terms of Service"
/// last, or even needs it at all) instead of hardcoding span order in Dart.
class LinkedText extends StatelessWidget {
  const LinkedText({
    required this.template,
    required this.tags,
    this.style,
    this.linkStyle,
    this.textAlign = TextAlign.start,
    super.key,
  });

  /// Text containing `{tagName}` placeholders, e.g.
  /// `"By continuing you agree to our {terms} and {privacy}"`.
  final String template;

  /// Maps each `{tagName}` placeholder to the label shown in its place and
  /// the callback fired on tap. A placeholder with no matching entry is
  /// left in the output as plain text.
  final Map<String, LinkedTextTag> tags;

  final TextStyle? style;
  final TextStyle? linkStyle;
  final TextAlign textAlign;

  static final _tagPattern = RegExp(r'\{(\w+)\}');

  @override
  Widget build(BuildContext context) {
    final defaultStyle = style ?? DefaultTextStyle.of(context).style;
    final resolvedLinkStyle =
        linkStyle ??
        defaultStyle.copyWith(
          color: context.colorScheme.primary,
          decoration: TextDecoration.underline,
          decorationColor: context.colorScheme.primary,
        );

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in _tagPattern.allMatches(template)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: template.substring(cursor, match.start)));
      }

      final tag = tags[match.group(1)];
      spans.add(
        tag == null
            ? TextSpan(text: match.group(0))
            : TextSpan(
                text: tag.text,
                style: resolvedLinkStyle,
                recognizer: TapGestureRecognizer()..onTap = tag.onTap,
              ),
      );

      cursor = match.end;
    }
    if (cursor < template.length) {
      spans.add(TextSpan(text: template.substring(cursor)));
    }

    return Text.rich(
      TextSpan(style: defaultStyle, children: spans),
      textAlign: textAlign,
    );
  }
}

class LinkedTextTag {
  const LinkedTextTag({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;
}
