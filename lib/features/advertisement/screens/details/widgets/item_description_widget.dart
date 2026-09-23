import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDescriptionWidget extends StatefulWidget {
  const ItemDescriptionWidget({required this.description, super.key});

  final String? description;

  @override
  State<ItemDescriptionWidget> createState() => _ItemDescriptionWidgetState();
}

class _ItemDescriptionWidgetState extends State<ItemDescriptionWidget> {
  bool _isExpanded = false;

  String _formatContent(String raw) {
    // If already contains HTML tags (e.g. from Quill editor or formatted_description)
    final hasHtml = RegExp(r'<[a-z][\s\S]*>', caseSensitive: false).hasMatch(raw);
    if (hasHtml) return raw;

    // Convert plain text:
    // 1. Detect Indian phone numbers (10 digits starting with 6, 7, 8, or 9, with optional +91 or 0 prefix)
    String formatted = raw.replaceAllMapped(
      RegExp(r'(?:(?:\+?91|0)?[ -]?)?([6-9]\d{9})\b'),
      (match) {
        final digits = match.group(1)!;
        return '<a href="tel:+91$digits" class="phone-badge">📞 +91 $digits</a>';
      },
    );

    // 2. Detect URLs
    formatted = formatted.replaceAllMapped(
      RegExp(r'(https?:\/\/[^\s<>"]+)'),
      (match) {
        final url = match.group(1)!;
        return '<a href="$url">$url</a>';
      },
    );

    // 3. Newlines
    formatted = formatted.replaceAll('\n', '<br/>');

    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.description == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomShimmer(width: 200, height: 20, borderRadius: 16),
            12.vGap,
            ...List.generate(
              5,
              (_) => const CustomShimmer(
                width: double.maxFinite,
                height: 20,
                borderRadius: 16,
                margin: EdgeInsets.symmetric(vertical: 2),
              ),
            ),
          ],
        ),
      );
    }

    final raw = widget.description!;
    final formattedHtml = _formatContent(raw);
    final isLong = raw.length > 250 || formattedHtml.contains('<br') || formattedHtml.contains('<p');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(
            'aboutThisItem'.translate(context),
            style: context.titleMedium.semiBold,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Stack(
              children: [
                ConstrainedBox(
                  constraints: _isExpanded
                      ? const BoxConstraints()
                      : const BoxConstraints(maxHeight: 180),
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: HtmlWidget(
                      formattedHtml,
                      textStyle: context.bodyMedium.copyWith(
                        color: context.colorScheme.onSurface,
                        height: 1.5,
                      ),
                      onTapUrl: (url) async {
                        final uri = Uri.tryParse(url);
                        if (uri != null) {
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                            return true;
                          }
                        }
                        return false;
                      },
                      customStylesBuilder: (element) {
                        if (element.classes.contains('eclassify-phone-badge') ||
                            element.classes.contains('phone-badge')) {
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          return {
                            'display': 'inline-block',
                            'padding': '2px 8px',
                            'background-color': isDark ? '#1e3a8a' : '#dbeafe',
                            'color': isDark ? '#93c5fd' : '#1d4ed8',
                            'border-radius': '6px',
                            'font-weight': '600',
                            'text-decoration': 'none',
                          };
                        }
                        if (element.localName == 'a') {
                          return {
                            'color': '#2563eb',
                            'text-decoration': 'underline',
                          };
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                if (!_isExpanded && isLong)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 60,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              context.colorScheme.surface.withValues(alpha: 0),
                              context.colorScheme.surface,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isLong)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    _isExpanded
                        ? 'readLess'.translate(context)
                        : 'readMore'.translate(context),
                    style: context.labelMedium.semiBold.copyWith(
                      color: context.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
