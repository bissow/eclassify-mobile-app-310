import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/features/chat/models/chat_message.dart';
import 'package:flutter/material.dart';

class OfferChatMessageWidget extends StatelessWidget {
  const OfferChatMessageWidget({
    required this.message,
    required this.username,
    super.key,
  });

  final OfferChatMessage message;
  final String username;

  @override
  Widget build(BuildContext context) {
    final isMe = message.senderId == AppSession.currentUser!.id;
    final name = isMe ? 'you'.translate(context) : '$username';
    return Center(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            'offerUpdatedMessage'.translate(context, {
              'amount': message.amount,
              'name': name,
            }),
            style: context.labelLarge,
          ),
        ),
      ),
    );
  }
}
