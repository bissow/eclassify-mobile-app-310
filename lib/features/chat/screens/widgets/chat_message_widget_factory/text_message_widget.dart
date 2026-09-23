import 'package:eClassify/features/chat/models/chat_message.dart';
import 'package:eClassify/features/chat/screens/widgets/clickable_url_text.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' show LinkPreviewData;
import 'package:flutter_link_previewer/flutter_link_previewer.dart';

final Map<int, LinkPreviewData> _linkPreviewCache = {};

class TextMessageWidget extends StatelessWidget {
  const TextMessageWidget({required this.message, super.key});

  final TextChatMessage message;

  @override
  Widget build(BuildContext context) {
    final cacheKey = message.message.hashCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return LinkPreview(
              onLinkPreviewDataFetched: (data) {
                _linkPreviewCache[cacheKey] = data;
              },
              text: message.message,
              linkPreviewData: _linkPreviewCache[cacheKey],
              minWidth: constraints.maxWidth,
              forcedLayout: LinkPreviewImagePosition.side,
              sideBorderColor: context.colorScheme.primary,
              backgroundColor: context.colorScheme.surfaceContainerLow,
              outsidePadding: const EdgeInsets.symmetric(vertical: 4),
              imageBuilder: (url) =>
                  CustomImage(src: url, fit: BoxFit.scaleDown),
            );
          },
        ),
        ClickableUrlText(text: message.message, style: context.labelLarge),
      ],
    );
  }
}
