import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/app_assets.dart';
import 'package:eClassify/core/widgets/images/svg_color_mapper.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/utils/image_url_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum _FileType { network, asset, file }

class CustomImage extends StatefulWidget {
  const CustomImage({
    required String? src,
    this.fit = BoxFit.cover,
    this.size,
    this.resolution,
    this.radius = 0,
    this.placeholder,
    this.errorImage,
    this.color,
    this.adaptive = true,
    this.quality = Constant.displayImageQuality,
    this.fadeDuration = Duration.zero,
    super.key,
  }) : this.src = src ?? '';

  final String src;
  final BoxFit fit;
  final Size? size;
  final Size? resolution;
  final double radius;
  final Widget? placeholder;
  final Widget? errorImage;

  /// When true, the image is decoded at the size it is painted and, for network
  /// images, requested from the server at that size too.
  final bool adaptive;

  /// Quality (`q`) requested from the server. Only used for adaptive network
  /// images.
  final int quality;

  /// Cross fade between placeholder and loaded image, for network images.
  ///
  /// Defaults to [Duration.zero]. A non zero fade keeps both the placeholder
  /// and the decoded image in the tree at once and composites them with
  /// opacity, which forces a `saveLayer` for the length of the animation. On a
  /// screen showing several full width images that is expensive enough to drop
  /// frames, so fading is opt in.
  final Duration fadeDuration;

  // This is ignored if the src has type other than SVG
  final Color? color;

  @override
  State<CustomImage> createState() => _CustomImageState();
}

class _CustomImageState extends State<CustomImage> {
  late bool _isSvg;
  late _FileType _fileType;

  Widget? _placeHolderImage;
  Widget? _errorImage;

  /// Built lazily and cached. Eagerly constructing an [SvgPicture] for every
  /// [CustomImage] costs a widget tree per card in a long list, and the error
  /// variant is almost never shown.
  Widget get placeHolderImage =>
      _placeHolderImage ??= widget.placeholder ?? _fallbackImage();

  Widget get errorImage =>
      _errorImage ??= widget.errorImage ?? _fallbackImage();

  Widget _fallbackImage() => SvgPicture.asset(
    AppAssets.branding.placeholder,
    height: height,
    width: width,
    fit: widget.fit,
  );

  double? get height => widget.size?.height;

  double? get width => widget.size?.width;

  Size? get res => widget.resolution ?? widget.size;

  @override
  void initState() {
    super.initState();
    _resolveImageProvider(widget.src);
  }

  @override
  void didUpdateWidget(covariant CustomImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src) {
      _resolveImageProvider(widget.src);
    }
    if (oldWidget.errorImage != widget.errorImage ||
        oldWidget.placeholder != widget.placeholder) {
      _placeHolderImage = null;
      _errorImage = null;
    }
  }

  void _resolveImageProvider(String src) {
    final uri = Uri.tryParse(src);
    if (uri == null) return;

    if (uri.hasScheme && ['http', 'https'].contains(uri.scheme)) {
      _fileType = _FileType.network;
    } else if (uri.path.contains('assets')) {
      _fileType = _FileType.asset;
    } else {
      _fileType = _FileType.file;
    }
    _isSvg = uri.pathSegments.lastOrNull?.endsWith('svg') ?? false;
  }

  double clampSize(double size, double dpr) {
    final scaledSize = size * dpr;
    // Removing the strict 700px cap to ensure sharpness on high-res devices.
    // Using a 2000px sanity cap instead.
    return min(scaledSize, 2000);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveMapper = widget.color == null
        ? SvgColorMapper.primary(color: context.colorScheme.primary)
        : SvgColorMapper(color: widget.color);

    Widget child;
    if (_isSvg) {
      child = switch (_fileType) {
        _FileType.asset => SvgPicture.asset(
          widget.src,
          height: height,
          width: width,
          fit: widget.fit,
          errorBuilder: (_, _, _) => errorImage,
          placeholderBuilder: (_) => placeHolderImage,
          colorMapper: effectiveMapper,
        ),
        _FileType.network => SvgPicture.network(
          widget.src,
          height: height,
          width: width,
          fit: widget.fit,
          errorBuilder: (_, _, _) => errorImage,
          placeholderBuilder: (_) => placeHolderImage,
          colorMapper: effectiveMapper,
        ),
        _FileType.file => SvgPicture.file(
          File(widget.src),
          height: height,
          width: width,
          fit: widget.fit,
          errorBuilder: (_, _, _) => errorImage,
          placeholderBuilder: (_) => placeHolderImage,
          colorMapper: effectiveMapper,
        ),
      };
    } else if (widget.adaptive && res == null) {
      // No explicit size was given, so fall back to whatever the parent
      // allocates. Needed for images laid out by their parent, e.g. the grid
      // variant of ItemCard.
      child = LayoutBuilder(
        builder: (context, constraints) => _buildRaster(
          context,
          Size(
            constraints.maxWidth.isFinite ? constraints.maxWidth : double.nan,
            constraints.maxHeight.isFinite ? constraints.maxHeight : double.nan,
          ),
        ),
      );
    } else {
      child = _buildRaster(context, res);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: SizedBox.fromSize(size: widget.size, child: child),
    );
  }

  /// Builds the non-SVG image, decoded (and for network images, fetched) at
  /// [target] logical size when [CustomImage.adaptive] is set.
  Widget _buildRaster(BuildContext context, Size? target) {
    final dpr = MediaQuery.of(context).devicePixelRatio;

    bool isUsable(double? value) =>
        value != null && value.isFinite && value > 0;

    // Only ever constrain a single axis. Passing both makes the decoder resize
    // to that exact box, which ignores the source aspect ratio and produces a
    // squashed bitmap that then gets scaled back up by [fit], looking blurry.
    // The widest axis is used so the image never lacks pixels for the space.
    final double? targetWidth = switch (target) {
      Size(:final width, :final height) when isUsable(width) =>
        isUsable(height) ? max(width, height) : width,
      Size(:final height) when isUsable(height) => height,
      _ => null,
    };

    final int? cacheWidth = widget.adaptive && targetWidth != null
        ? clampSize(targetWidth, dpr).toInt()
        : null;

    return switch (_fileType) {
      _FileType.asset => Image.asset(
        widget.src,
        height: height,
        width: width,
        fit: widget.fit,
        cacheWidth: cacheWidth,
        errorBuilder: (_, _, _) => errorImage,
      ),
      _FileType.network => CachedNetworkImage(
        imageUrl: _resolveNetworkSrc(cacheWidth),
        imageBuilder: (context, provider) {
          return Image(
            image: provider,
            height: height,
            width: width,
            fit: widget.fit,
          );
        },
        memCacheWidth: cacheWidth,
        // maxWidthDiskCache is deliberately not set: it re-encodes every
        // downloaded file before caching it, which costs more than it saves now
        // that the server hands us an already resized image.
        fadeInDuration: widget.fadeDuration,
        fadeOutDuration: widget.fadeDuration,
        errorWidget: (_, _, _) => errorImage,
        placeholder: (_, _) => placeHolderImage,
      ),
      _FileType.file => Image.file(
        File(widget.src),
        height: height,
        width: width,
        fit: widget.fit,
        cacheWidth: cacheWidth,
        errorBuilder: (_, _, _) => errorImage,
      ),
    };
  }

  /// Asks the server for an already resized image so we do not download the
  /// full resolution original just to paint a thumbnail.
  ///
  /// Only `w` is sent. Sending `h` too would let the server crop to a different
  /// aspect ratio than the one [CustomImage.fit] crops to on the client.
  String _resolveNetworkSrc(int? cacheWidth) {
    if (cacheWidth == null) return widget.src;

    // Snap to a tier so the same image resolves to the same URL across devices,
    // keeping the CDN and disk cache warm.
    return ImageUrlUtils.withImageParams(
      widget.src,
      width: ImageUrlUtils.snapToTier(cacheWidth.toDouble()),
      quality: widget.quality,
    );
  }
}
