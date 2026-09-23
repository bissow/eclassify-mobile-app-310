import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/date_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/features/chat/cubits/chat_message_cubit.dart';
import 'package:eClassify/features/chat/models/chat_message.dart';
import 'package:eClassify/features/chat/screens/widgets/chat_bubble.dart';
import 'package:eClassify/features/chat/screens/widgets/chat_message_widget_factory/chat_message_widget_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({
    required this.message,
    required this.isMe,
    this.isSelected = false,
    this.showTime = true,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  final ChatMessage message;
  final bool isMe;
  final bool isSelected;
  final bool showTime;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final child = ChatMessageWidgetFactory.create(message);

    return ColoredBox(
      color: isSelected
          ? context.colorScheme.primary.withValues(alpha: .2)
          : Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Constant.horizontalPadding,
          vertical: showTime ? 8 : 4,
        ),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            spacing: 5,
            children: [
              _buildBubbleWithProgress(
                context,
                child,
                isOfferMessage: message is OfferChatMessage,
              ),
              if (showTime) _buildTimeAndStatus(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBubbleWithProgress(
    BuildContext context,
    Widget child, {
    bool isOfferMessage = false,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * .8,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ChatBubble(
            isMe: isMe,
            color: isOfferMessage ? context.colorScheme.primary : null,
            child: Padding(padding: const EdgeInsets.all(12.0), child: child),
          ),
          if (message.isSending && message.uploadProgress != null)
            Positioned(
              bottom: -2,
              left: 12,
              right: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: message.uploadProgress,
                  minHeight: 2,
                  backgroundColor: context.colorScheme.surface.withAlpha(100),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeAndStatus(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message.dateTime.format(formatString: DateFormat.HOUR_MINUTE),
          style: context.labelSmall.muted(context),
        ),
        if (isMe) ...[const SizedBox(width: 4), _buildStatusIcon(context)],
      ],
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    if (message.isSending) {
      return Icon(
        AppIcons.clock,
        size: 14,
        color: context.colorScheme.onSurfaceVariant.withAlpha(150),
      );
    }
    if (message.isFailed) {
      return GestureDetector(
        onTap: () {
          if (message.localId != null) {
            context.read<ChatMessageCubit>().retryMessage(message.localId!);
          }
        },
        child: Icon(
          AppIcons.warningCircle,
          size: 16,
          color: context.colorScheme.error,
        ),
      );
    }
    // Success state: no icon as per feedback
    return const SizedBox.shrink();
  }
}
