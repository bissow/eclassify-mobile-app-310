import 'dart:io';

import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/images/full_screen_image_view.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/widgets/images/scaled_network_image.dart';
import 'package:flutter/material.dart';

class FileWidget extends StatelessWidget {
  const FileWidget({
    required this.url,
    this.keepAspectRatioForImage = true,
    this.size,
    super.key,
  });

  final String url;
  final bool keepAspectRatioForImage;

  /// Used if the file is of type image
  /// Ignored if the file is not of type image and keepAspectRatioForImage is true
  final Size? size;

  bool get _isImageFile {
    final extensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    final extension = url.split('.').last.toLowerCase();
    return extensions.any((ext) => extension.contains(ext));
  }

  bool get _isNetworkUrl => url.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final isImage = _isImageFile;
    return GestureDetector(
      onTap: () {
        if (isImage) {
          FullScreenImageView.show(context, url);
        }
      },
      child: isImage
          ? _ImageWidget(
              url,
              keepAspectRatioForImage: keepAspectRatioForImage,
              size: size,
              isNetwork: _isNetworkUrl,
            )
          : _FileWidget(url, isNetwork: _isNetworkUrl),
    );
  }
}

class _ImageWidget extends StatelessWidget {
  const _ImageWidget(
    this.url, {
    this.keepAspectRatioForImage = true,
    this.size,
    required this.isNetwork,
  });

  final String url;
  final bool keepAspectRatioForImage;
  final Size? size;
  final bool isNetwork;

  @override
  Widget build(BuildContext context) {
    if (!isNetwork) {
      // Local image handling
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(url),
          fit: BoxFit.cover,
          width: size?.width,
          height: size?.height,
        ),
      );
    }

    if (keepAspectRatioForImage) {
      return ScaledNetworkImage(key: ValueKey(url), url: url);
    } else {
      return CustomImage(src: url, size: size, fit: BoxFit.cover, radius: 6);
    }
  }
}

class _FileWidget extends StatelessWidget {
  const _FileWidget(this.url, {required this.isNetwork});

  final String url;
  final bool isNetwork;

  @override
  Widget build(BuildContext context) {
    final fileName = isNetwork
        ? Uri.parse(url).pathSegments.last
        : url.split('/').last;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(AppIcons.copy),
      title: Text(fileName, maxLines: 3, overflow: TextOverflow.ellipsis),
      trailing: isNetwork
          ? const Icon(AppIcons.downloadSimple)
          : const Icon(AppIcons.uploadSimple),
    );
  }
}
