import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:flutter/material.dart';

class FullScreenImageView extends StatelessWidget {
  const FullScreenImageView._({required this.src});

  final String src;

  /// Pushes [src] full screen over a translucent, tap-to-dismiss barrier
  /// rather than a full [MaterialPageRoute], since there's no real "page"
  /// underneath — just a zoomable image over whatever was already showing.
  static Future<void> show(BuildContext context, String src) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) =>
            FullScreenImageView._(src: src),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: InteractiveViewer(
        maxScale: 4,
        child: Center(child: CustomImage(src: src)),
      ),
    );
  }
}
