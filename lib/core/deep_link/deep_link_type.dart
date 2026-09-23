import 'package:collection/collection.dart';

enum DeepLinkType {
  adDetails('ad-details'),
  seller('seller'),
  reel('reel'),
  blogs('blogs');

  const DeepLinkType(this.path);

  final String path;

  static DeepLinkType? fromUri(Uri uri) {
    return DeepLinkType.values.firstWhereOrNull(
      (t) => uri.pathSegments.contains(t.path),
    );
  }
}
