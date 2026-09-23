import 'package:eClassify/features/reels/models/video_ad.dart';
import 'package:eClassify/features/reels/screens/widgets/reel_actions.dart';
import 'package:eClassify/features/reels/screens/widgets/reel_item_card.dart';
import 'package:eClassify/features/reels/screens/widgets/reel_user_card.dart';
import 'package:flutter/material.dart';

class ReelFeedHudOverlay extends StatelessWidget {
  const ReelFeedHudOverlay({
    required this.videoAd,
    required this.isMutedNotifier,
    super.key,
  });

  final VideoAd videoAd;
  final ValueNotifier<bool> isMutedNotifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 32,
      children: [
        Expanded(
          child: Column(
            spacing: 16,
            children: [
              if (videoAd.seller != null) ReelUserCard(user: videoAd.seller!),
              ReelItemCard(item: videoAd.item),
            ],
          ),
        ),
        ReelActions(ad: videoAd, isMutedNotifier: isMutedNotifier),
      ],
    );
  }
}
