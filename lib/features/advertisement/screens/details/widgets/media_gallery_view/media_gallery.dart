import 'dart:async';

import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/media_gallery_view/gallery_screen.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/media_gallery_view/video_player_widget.dart';
import 'package:eClassify/features/item/models/product_video.dart';
import 'package:flutter/material.dart';

class MediaGallery extends StatefulWidget {
  const MediaGallery({
    required this.controller,
    required this.images,
    this.video,
    this.allowAutoSlider = true,
    this.isFullScreen = false,
    super.key,
  });

  final PageController controller;
  final List<String> images;
  final ProductVideo? video;
  final bool allowAutoSlider;
  final bool isFullScreen;

  @override
  State<MediaGallery> createState() => _MediaGalleryState();
}

class _MediaGalleryState extends State<MediaGallery> {
  final TransformationController _transformationController =
      TransformationController();
  Timer? _timer;
  late final List<String> _images = widget.images;
  late final int _totalPages;

  bool get _hasVideo => widget.video != null;

  @override
  void initState() {
    super.initState();
    _setTotalPages();
    if (widget.allowAutoSlider) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTimer();
      });
    }
  }

  @override
  void dispose() {
    _clearTimer();
    _transformationController.dispose();
    super.dispose();
  }

  void _setTotalPages() {
    var count = _images.length;
    if (_hasVideo) {
      count++;
    }
    _totalPages = count;
  }

  void _clearTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startTimer() {
    _clearTimer();
    if (_totalPages > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) => _nextPage());
    }
  }

  void _nextPage() {
    if (!mounted || _totalPages <= 1) return;
    final currentPage = widget.controller.page?.round() ?? 0;
    final nextPage = (currentPage + 1) % _totalPages;

    widget.controller.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.isFullScreen) return;
        final index = widget.controller.page?.toInt() ?? 0;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryScreen(
              images: widget.images,
              video: widget.video,
              initialIndex: index,
            ),
          ),
        );
      },
      child: PageView.builder(
        controller: widget.controller,
        itemCount: _totalPages,
        itemBuilder: (context, index) {
          final isVideo = _hasVideo && index == _totalPages - 1;
          return Padding(
            padding: widget.isFullScreen
                ? EdgeInsets.zero
                : Constant.pagePadding,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.isFullScreen ? 0 : 16),
              child: isVideo
                  ? VideoPlayerWidget(
                      videoUrl: widget.video!.videoSource.filePath,
                      type: widget.video!.type,
                    )
                  : GestureDetector(
                      behavior: HitTestBehavior.deferToChild,
                      onDoubleTap: () {
                        _transformationController.value = Matrix4.identity();
                      },
                      child: InteractiveViewer(
                        transformationController: _transformationController,
                        maxScale: 5,
                        panEnabled: widget.isFullScreen,
                        scaleEnabled: widget.isFullScreen,
                        child: CustomImage(
                          src: _images[index],
                          size: null,
                          fit: widget.isFullScreen
                              ? BoxFit.scaleDown
                              : BoxFit.cover,
                          // Full screen allows zooming up to 5x, so it needs the
                          // original. The inline carousel does not.
                          adaptive: false,
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
