import 'package:collection/collection.dart';

enum DeepLinkType {
  adDetails('ad-details'),
  seller('seller'),
  reel('reel'),
  blogs('blogs'),
  storeQr('store-qr');

  const DeepLinkType(this.path);

  final String path;

  static DeepLinkType? fromUri(Uri uri) {
    if (uri.scheme == 'eclassify' && (uri.host == 'store-qr' || uri.pathSegments.contains('store-qr'))) {
      return DeepLinkType.storeQr;
    }
    return DeepLinkType.values.firstWhereOrNull(
      (t) => uri.pathSegments.contains(t.path),
    );
  }
}

