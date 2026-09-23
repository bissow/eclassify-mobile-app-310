import 'package:eClassify/core/constants/constant.dart';

/// Helpers to request server side resized images instead of downloading the
/// original full resolution file.
///
/// The backend accepts `w`, `h` and `q` query parameters on image URLs, so the
/// widget layer can ask for roughly the size it actually paints.
final class ImageUrlUtils {
  const ImageUrlUtils._();

  /// Fixed width ladder.
  ///
  /// Snapping to a small set of widths keeps both the CDN cache and
  /// CachedNetworkImage's disk cache keys stable across devices and screen
  /// sizes. Without it, every distinct card width would produce its own URL.
  static const List<int> widthTiers = [480, 720, 1080, 1440, 2000];

  /// Rounds [physicalPx] up to the nearest tier, capped at the largest one.
  static int snapToTier(double physicalPx) => widthTiers.firstWhere(
    (tier) => tier >= physicalPx,
    orElse: () => widthTiers.last,
  );

  /// Appends `w`, `h` and `q` to a network image URL, preserving any query
  /// parameters that are already present.
  ///
  /// Returns [url] untouched when it is not an http(s) URL, when it points to
  /// an SVG (nothing to resize), or when [width] is null.
  static String withImageParams(
    String url, {
    int? width,
    int? height,
    int quality = Constant.displayImageQuality,
  }) {
    if (width == null || url.isEmpty) return url;

    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    if (!uri.hasScheme || !['http', 'https'].contains(uri.scheme)) return url;
    if (uri.pathSegments.lastOrNull?.endsWith('svg') ?? false) return url;

    return uri
        .replace(
          queryParameters: {
            ...uri.queryParameters,
            'w': '$width',
            if (height != null) 'h': '$height',
            'q': '$quality',
          },
        )
        .toString();
  }
}
