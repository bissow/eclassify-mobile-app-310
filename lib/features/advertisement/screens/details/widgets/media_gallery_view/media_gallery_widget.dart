import 'package:eClassify/features/item/models/item.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/media_gallery_view/media_gallery_view.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/features/item/extensions/item_extension.dart';
import 'package:flutter/material.dart';

/// Placeholder until the API call is completed which returns list of images
/// When the API call is active:
/// => previewImage != null => show the image
/// => previewImage == null => show shimmer
/// When the API call is completed:
/// Replace with [MediaGalleryView]
class MediaGalleryWidget extends StatelessWidget {
  const MediaGalleryWidget({this.previewImage, this.item, super.key});

  final String? previewImage;
  final Item? item;

  @override
  Widget build(BuildContext context) {
    if (item != null) {
      return MediaGalleryView(item: item!, isMyItem: item!.isMyAd);
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Constant.horizontalPadding,
        vertical: 8,
      ),
      child: Builder(
        builder: (context) {
          if (previewImage.isNotNullAndNotEmpty) {
            final imageSize = context.sizeFromAspectRatio(16 / 9);
            return AspectRatio(
              aspectRatio: 16 / 9,
              child: CustomImage(
                src: previewImage,
                size: imageSize,
                fit: BoxFit.cover,
                radius: 16,
                adaptive: true,
              ),
            );
          } else {
            return AspectRatio(
              aspectRatio: 16 / 9,
              child: CustomShimmer(borderRadius: 16),
            );
          }
        },
      ),
    );
  }
}
