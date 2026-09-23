import 'package:eClassify/features/chat/models/chat_message.dart';
import 'package:eClassify/features/chat/screens/widgets/chat_message_widget_factory/file_widget.dart';
import 'package:eClassify/features/chat/screens/widgets/clickable_url_text.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';

class FileTextMessageWidget extends StatelessWidget {
  const FileTextMessageWidget({required this.message, super.key});

  final FileAndTextMessage message;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: context.screenWidth * .7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          FileWidget(
            url: message.file,
            keepAspectRatioForImage: false,
            size: Size.fromHeight(250),
          ),
          ClickableUrlText(text: message.message, style: context.labelLarge),
        ],
      ),
    );
  }
}
