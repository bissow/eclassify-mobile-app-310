import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// WhatsApp-style mic trigger: a single tap starts recording. All in-progress
/// controls (delete / pause / send) live in the recording panel, so this
/// button has no gesture handling of its own.
class MessageAudioButton extends StatelessWidget {
  const MessageAudioButton({required this.onRecordStart, super.key});

  final Future<bool> Function() onRecordStart;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: context.colorScheme.primary,
        foregroundColor: context.colorScheme.onPrimary,
        fixedSize: const Size.square(40),
        iconSize: 24,
      ),
      onPressed: () async {
        final started = await onRecordStart();
        if (started) HapticFeedback.vibrate();
      },
      icon: const Icon(AppIcons.microphoneFill),
    );
  }
}
