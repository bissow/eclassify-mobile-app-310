import 'package:eClassify/features/item/models/ad_item_type.dart';
import 'package:eClassify/features/item/models/item.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/media_gallery_view/media_gallery.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/media_gallery_view/reel_view_widget.dart';
import 'package:eClassify/features/favorite/screens/widgets/favorite_button.dart';
import 'package:eClassify/features/onboarding/screens/widgets/page_indicator.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:flutter/material.dart';

class MediaGalleryView extends StatefulWidget {
  const MediaGalleryView({
    required this.item,
    required this.isMyItem,
    super.key,
  });

  final Item item;
  final bool isMyItem;

  @override
  State<MediaGalleryView> createState() => _MediaGalleryViewState();
}

class _MediaGalleryViewState extends State<MediaGalleryView> {
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _currentIndexNotifier.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isMyItem = widget.isMyItem;

    // gallery_images already contains the main image, flagged is_default, so it
    // only needs ordering rather than adding. Sorting here instead of trusting
    // the response order guarantees the main image is the first page.
    final images = item.images ?? const [];
    final galleryImages = <String>[
      ...images.where((e) => e.isDefault).map((e) => e.url),
      ...images.where((e) => !e.isDefault).map((e) => e.url),
      // Fall back to the main image if the gallery came back empty.
      if (images.isEmpty && item.image.isNotEmpty) item.image,
    ];

    int totalPages = galleryImages.length + (item.video != null ? 1 : 0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          // The inner item will have horizontal padding applied, so we calculate
          // the height based on the padded width to maintain a perfect 16:9 ratio inside.
          final double innerWidth = width - (Constant.horizontalPadding * 2);
          // 13 is retrieved from Column spacing + height of page indicator
          final double targetHeight =
              innerWidth * (9 / 16) + (totalPages > 1 ? 13 : 0);

          return SizedBox(
            height: targetHeight,
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5,
                  children: [
                    Expanded(
                      child: MediaGallery(
                        controller: _pageController,
                        images: galleryImages,
                        video: item.video,
                        allowAutoSlider: false,
                      ),
                    ),
                    if (totalPages > 1)
                      PageIndicator(
                        controller: _pageController,
                        count: totalPages,
                      ),
                  ],
                ),
                PositionedDirectional(
                  end: Constant.horizontalPadding + 8,
                  top: 8,
                  child: FavoriteButton(itemId: item.id, isLiked: item.isLiked),
                ),
                if (item.type == AdItemType.videoAd)
                  PositionedDirectional(
                    end: Constant.horizontalPadding + 8,
                    bottom: 16 + (totalPages > 1 ? 13 : 0),
                    child: ListenableBuilder(
                      listenable: _pageController,
                      builder: (context, _) {
                        final currentIndex = _pageController.page?.toInt() ?? 0;
                        bool isVideoPage =
                            (item.video != null) &&
                            (currentIndex == totalPages - 1);
                        if (isVideoPage) return const SizedBox.shrink();

                        return ReelViewWidget(
                          itemId: item.id,
                          isMyReel: isMyItem,
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
