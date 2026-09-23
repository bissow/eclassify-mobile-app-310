import 'package:eClassify/core/deep_link/deep_link_dispatcher.dart';
import 'package:eClassify/core/deep_link/deep_link_handler.dart';
import 'package:eClassify/core/deep_link/deep_link_target.dart';
import 'package:flutter/widgets.dart';

mixin DeepLinkAware<S extends StatefulWidget, T extends DeepLinkTarget>
    on State<S> {
  final _dispatcher = DeepLinkDispatcher.instance;

  late final DeepLinkHandler<T> _handler = createHandler();

  DeepLinkHandler<T> createHandler();

  bool get shouldHandlePendingLink => true;

  bool get isDeepLinkPending {
    final pending = _dispatcher.lastTarget;
    return pending != null && _handler.canHandle(pending);
  }

  @override
  void initState() {
    super.initState();
    _dispatcher.registerHandler(_handler);
    if (shouldHandlePendingLink) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dispatcher.handleLastLinkIfAny();
      });
    }
  }

  @override
  void dispose() {
    _dispatcher.removeHandler(_handler);
    super.dispose();
  }
}
