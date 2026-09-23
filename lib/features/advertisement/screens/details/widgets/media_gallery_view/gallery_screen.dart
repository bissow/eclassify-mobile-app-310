import 'package:eClassify/features/item/models/product_video.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/media_gallery_view/media_gallery.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/widgets/ads/interstitial_ad_on_exit_mixin.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({
    required this.images,
    this.video,
    this.initialIndex = 0,
    super.key,
  });

  final List<String> images;
  final ProductVideo? video;
  final int initialIndex;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with InterstitialAdOnExitMixin {
  late final PageController _pageController = PageController(
    initialPage: widget.initialIndex,
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withValues(alpha: .4),
            child: IconButton(
              icon: const Icon(AppIcons.x, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: Constant.pagePadding.copyWith(top: Constant.verticalPadding).copyWith(
          bottom: MediaQuery.paddingOf(context).bottom + 20,
        ),
        child: MediaGallery(
          controller: _pageController,
          images: widget.images,
          video: widget.video,
          allowAutoSlider: false,
          isFullScreen: true,
        ),
      ),
    );
  }
}
