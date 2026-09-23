import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/deep_link/deep_link_dispatcher.dart';
import 'package:eClassify/core/deep_link/deep_link_handler.dart';
import 'package:eClassify/core/deep_link/deep_link_target.dart';
import 'package:flutter/material.dart';

class DeepLinkListener extends StatefulWidget {
  const DeepLinkListener({required this.child, super.key});

  final Widget child;

  @override
  State<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends State<DeepLinkListener> {
  final _deepLinkDispatcher = DeepLinkDispatcher.instance;
  final _appLinks = AppLinks();

  StreamSubscription<Uri>? _deeplinkStream;

  @override
  void initState() {
    super.initState();
    _deepLinkDispatcher.setGlobalDeepLinkHandler(
      GlobalDeepLinkHandler(onLink: _deepLinkHandler),
    );
    _deeplinkStream = _appLinks.uriLinkStream.listen(_dispatchDeepLink);
  }

  @override
  void dispose() {
    _deeplinkStream?.cancel();
    super.dispose();
  }

  void _dispatchDeepLink(Uri link) {
    final target = DeepLinkTarget.parse(link);
    if (target == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deepLinkDispatcher.dispatch(target);
    });
  }

  Future<void> _deepLinkHandler(DeepLinkTarget target) async {
    switch (target) {
      case ItemDeepLink(:final slug):
        Navigator.pushNamed(
          context,
          Routes.adDetailsScreen,
          arguments: {'slug': slug},
        );
        break;
      case ReelDeepLink(:final id):
        Navigator.pushNamed(
          context,
          Routes.videoAdsScreen,
          arguments: {'reel_id': id},
        );
        break;
      case SellerDeepLink(:final id):
        Navigator.pushNamed(
          context,
          Routes.sellerProfileScreen,
          arguments: {'seller_id': id},
        );
        break;
      case BlogDeepLink(:final slug):
        Navigator.pushNamed(
          context,
          Routes.blogDetailsScreen,
          arguments: {'slug': slug},
        );
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
