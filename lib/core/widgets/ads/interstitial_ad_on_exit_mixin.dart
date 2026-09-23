import 'package:eClassify/core/widgets/ads/intertitial_ads_screen.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:flutter/material.dart';

mixin InterstitialAdOnExitMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    if (Constant.systemSettings.isInterstitialAdEnabled) {
      InterstitialAdHelper.loadInterstitialAd(
        Constant.systemSettings.interstitialAdId!,
      );
    }
  }

  @override
  void dispose() {
    InterstitialAdHelper.showInterstitialAd();
    super.dispose();
  }
}
