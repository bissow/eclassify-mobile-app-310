import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ClickableUrlText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const ClickableUrlText({super.key, required this.text, this.style});

  @override
  State<ClickableUrlText> createState() => _ClickableUrlTextState();
}

class _ClickableUrlTextState extends State<ClickableUrlText> {
  final RegExp _urlRegExp = RegExp(r'''https?://[^\s<>"']*[^\s<>"'.,!?;:)]''');
  List<InlineSpan> _spans = [];

  // The recognizers are not disposed automatically as they are not tied to a
  // widget lifecycle. The TextSpan itself is just a simple configuration object
  // and not a widget. Hence, we store recognizers to later discard them in dispose
  // method when the widget is no longer visible.
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void initState() {
    super.initState();
    _parseText();
  }

  @override
  void didUpdateWidget(covariant ClickableUrlText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text || widget.style != oldWidget.style) {
      _parseText();
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  void _parseText() {
    _disposeRecognizers();
    _spans = [];

    int lastMatchEnd = 0;

    for (final Match match in _urlRegExp.allMatches(widget.text)) {
      if (match.start > lastMatchEnd) {
        _spans.add(
          TextSpan(text: widget.text.substring(lastMatchEnd, match.start)),
        );
      }

      final String urlString = match.group(0)!;
      final recognizer = TapGestureRecognizer()
        ..onTap = () async {
          final Uri? uri = Uri.tryParse(urlString);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        };
      _recognizers.add(recognizer);

      _spans.add(
        TextSpan(
          text: urlString,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
            decorationColor: Colors.blue,
          ),
          recognizer: recognizer,
        ),
      );

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < widget.text.length) {
      _spans.add(TextSpan(text: widget.text.substring(lastMatchEnd)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(TextSpan(children: _spans), style: widget.style);
  }
}
