import 'package:eClassify/core/deep_link/deep_link_type.dart';

abstract class DeepLinkTarget {
  const DeepLinkTarget();

  /// The path segment identifying this target's kind, e.g. `ad-details`.
  DeepLinkType get type;

  /// The path segment identifying this specific instance, e.g. an item slug.
  String get value;

  /// Returns `null` for any URI that isn't one of this app's own deep link
  /// shapes. `uriLinkStream` is a single, app-wide stream — it also
  /// delivers URIs from other plugins' registered schemes (e.g. Firebase
  /// Auth/Google Sign-In's OAuth redirect), which are expected, routine
  /// traffic here, not an error condition.
  static DeepLinkTarget? parse(Uri link) {
    final type = DeepLinkType.fromUri(link);
    final path = link.pathSegments;

    return switch (type) {
      DeepLinkType.adDetails => ItemDeepLink(path.last),
      DeepLinkType.seller => SellerDeepLink(int.parse(path.last)),
      DeepLinkType.reel => ReelDeepLink(int.parse(path.last)),
      DeepLinkType.blogs => BlogDeepLink(path.last),
      DeepLinkType.storeQr => () {
        if (link.pathSegments.contains('store-qr')) {
          final idx = link.pathSegments.indexOf('store-qr');
          if (idx + 1 < link.pathSegments.length) {
            return StoreQrDeepLink(link.pathSegments[idx + 1]);
          }
        }
        return StoreQrDeepLink(path.isNotEmpty ? path.last : '');
      }(),
      null => null,
    };
  }
}


final class ItemDeepLink extends DeepLinkTarget {
  const ItemDeepLink(this.slug);

  final String slug;

  @override
  DeepLinkType get type => DeepLinkType.adDetails;

  @override
  String get value => slug;
}

final class ReelDeepLink extends DeepLinkTarget {
  const ReelDeepLink(this.id);

  final int id;

  @override
  DeepLinkType get type => DeepLinkType.reel;

  @override
  String get value => id.toString();
}

final class SellerDeepLink extends DeepLinkTarget {
  const SellerDeepLink(this.id);

  final int id;

  @override
  DeepLinkType get type => DeepLinkType.seller;

  @override
  String get value => id.toString();
}

final class BlogDeepLink extends DeepLinkTarget {
  const BlogDeepLink(this.slug);

  final String slug;

  @override
  DeepLinkType get type => DeepLinkType.blogs;

  @override
  String get value => slug;
}

final class StoreQrDeepLink extends DeepLinkTarget {
  const StoreQrDeepLink(this.token);

  final String token;

  @override
  DeepLinkType get type => DeepLinkType.storeQr;

  @override
  String get value => token;
}

