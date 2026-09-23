import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class BlobBorderShape extends OutlinedBorder {
  const BlobBorderShape({BorderSide side = BorderSide.none})
    : super(side: side);

  static final _svgPath = '''M43.74 6.312C40.308 2.4 32.94 0 24.012 0C15.084 0 
  7.716 2.4 4.284 6.312C-1.428 12.936 -1.428 35.112 4.284 41.688C7.716 45.6 
  15.084 48 24.012 48C32.94 48 40.308 45.6 43.74 41.688C49.452 35.064 49.452 
  12.936 43.74 6.312Z''';

  static final _path = parseSvgPathData(_svgPath);
  static final Rect _pathBounds = _path.getBounds();

  static Path centeredPathFor(Rect rect) {
    final offset = rect.center - _pathBounds.center;
    return _path.shift(offset);
  }

  @override
  OutlinedBorder copyWith({BorderSide? side}) => BlobBorderShape();

  Path _centeredPath(Rect rect) => centeredPathFor(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _centeredPath(rect);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  ShapeBorder scale(double t) {
    return BlobBorderShape(side: side.scale(t));
  }

  @override
  bool get preferPaintInterior => false;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _centeredPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    canvas.drawPath(getOuterPath(rect), paint);
  }
}

/// Paints a blur-shadow behind the blob shape, matching [BlobBorderShape]'s
/// outline instead of Material's rectangular/circular elevation shadow.
class BlobShadowPainter extends CustomPainter {
  const BlobShadowPainter({required this.shadow});

  final BoxShadow shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = BlobBorderShape.centeredPathFor(rect).shift(shadow.offset);
    canvas.drawPath(path, shadow.toPaint());
  }

  @override
  bool shouldRepaint(covariant BlobShadowPainter oldDelegate) =>
      oldDelegate.shadow != shadow;
}
