import 'package:eClassify/core/deep_link/deep_link_target.dart';
import 'package:flutter/foundation.dart';

abstract class DeepLinkHandler<T extends DeepLinkTarget> {
  bool canHandle(DeepLinkTarget target) => target is T;

  void handle(covariant T target);
}

class GlobalDeepLinkHandler extends DeepLinkHandler<DeepLinkTarget> {
  GlobalDeepLinkHandler({required this.onLink});

  final ValueChanged<DeepLinkTarget> onLink;

  @override
  void handle(DeepLinkTarget target) => onLink.call(target);
}

class ItemLinkHandler extends DeepLinkHandler<ItemDeepLink> {
  ItemLinkHandler({required this.onSlug});

  final ValueChanged<String> onSlug;

  @override
  void handle(ItemDeepLink target) => onSlug.call(target.slug);
}

class ReelLinkHandler extends DeepLinkHandler<ReelDeepLink> {
  ReelLinkHandler({required this.onId});

  final ValueChanged<int> onId;

  @override
  void handle(ReelDeepLink target) => onId.call(target.id);
}

class SellerLinkHandler extends DeepLinkHandler<SellerDeepLink> {
  SellerLinkHandler({required this.onId});

  final ValueChanged<int> onId;

  @override
  void handle(SellerDeepLink target) => onId.call(target.id);
}

class BlogLinkHandler extends DeepLinkHandler<BlogDeepLink> {
  BlogLinkHandler({required this.onSlug});

  final ValueChanged<String> onSlug;

  @override
  void handle(BlogDeepLink target) => onSlug.call(target.slug);
}
