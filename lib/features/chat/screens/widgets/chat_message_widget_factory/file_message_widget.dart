import 'package:eClassify/features/chat/models/chat_message.dart';
import 'package:eClassify/features/chat/screens/widgets/chat_message_widget_factory/file_widget.dart';
import 'package:flutter/material.dart';

class FileMessageWidget extends StatelessWidget {
  const FileMessageWidget({required this.message, super.key});

  final FileChatMessage message;

  @override
  Widget build(BuildContext context) {
    return FileWidget(key: ValueKey(message.id), url: message.file);
  }
}
