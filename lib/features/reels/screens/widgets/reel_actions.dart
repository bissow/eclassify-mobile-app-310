import 'package:eClassify/core/deep_link/deep_link_target.dart';
import 'package:eClassify/core/utils/share_utility.dart';
import 'package:eClassify/features/reels/models/video_ad.dart';
import 'package:eClassify/features/reels/screens/widgets/reel_chat_button.dart';
import 'package:eClassify/features/reels/screens/widgets/reel_like_button.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/tap_guard.dart';
import 'package:flutter/material.dart';

class ReelActions extends StatelessWidget {
  const ReelActions({
    required this.ad,
    required this.isMutedNotifier,
    super.key,
  });

  final VideoAd ad;
  final ValueNotifier<bool> isMutedNotifier;

  @override
  Widget build(BuildContext context) {
    final myId = AppSession.currentUser?.id;
    final TapGuard _guard = TapGuard();
    return Theme(
      data: context.theme.copyWith(
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: .2),
            foregroundColor: Colors.white,
            minimumSize: Size.square(40),
            fixedSize: Size.square(40),
          ),
        ),
      ),
      child: Column(
        spacing: 24,
        children: [
          ReelLikeButton(ad: ad),
          if (myId != ad.item.userId.toString()) ReelChatButton(ad: ad),
          _IconButtonWithText(
            onPressed: () {
              _guard.run(() async {
                ShareUtility.share(context, ReelDeepLink(ad.id));
              });
            },
            icon: AppIcons.shareNetwork,
            text: 'share'.translate(context),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: isMutedNotifier,
            builder: (context, isMuted, child) {
              return _IconButtonWithText(
                onPressed: () {
                  isMutedNotifier.value = !isMuted;
                },
                icon: isMuted ? AppIcons.speakerX : AppIcons.speakerHigh,
                text: 'sound'.translate(context),
              );
            },
          ),
          8.vGap,
        ],
      ),
    );
  }
}

class _IconButtonWithText extends StatelessWidget {
  const _IconButtonWithText({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  final IconData icon;
  final String? text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(onPressed: onPressed, icon: Icon(icon)),
        if (text.isNotNullAndNotEmpty)
          Text(text!, style: context.titleSmall.withColor(Colors.white)),
      ],
    );
  }
}
