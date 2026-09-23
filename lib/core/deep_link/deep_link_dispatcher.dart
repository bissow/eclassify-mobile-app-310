import 'package:eClassify/core/deep_link/deep_link_handler.dart';
import 'package:eClassify/core/deep_link/deep_link_target.dart';

class DeepLinkDispatcher {
  DeepLinkDispatcher._internal();

  static final DeepLinkDispatcher _instance = DeepLinkDispatcher._internal();

  static DeepLinkDispatcher get instance => _instance;

  final List<DeepLinkHandler> _handlers = List<DeepLinkHandler>.empty(
    growable: true,
  );
  bool _wasHandled = false;
  DeepLinkTarget? _lastTarget;

  DeepLinkTarget? get lastTarget => _lastTarget;

  DeepLinkHandler? _globalDeepLinkHandler;

  //Because if we make it setter then we need to have getters also which has no
  //real use case here, but very_good_analysis puts that annoying squiggly lines
  //hence we ignore this rule.
  //ignore: use_setters_to_change_properties
  void setGlobalDeepLinkHandler(DeepLinkHandler deepLinkHandler) {
    _globalDeepLinkHandler = deepLinkHandler;
  }

  void registerHandler(DeepLinkHandler handler) {
    _handlers.insert(0, handler);
  }

  void removeHandler(DeepLinkHandler handler) {
    _handlers.remove(handler);
  }

  void dispatch(DeepLinkTarget target) {
    _lastTarget = target;
    _wasHandled = false;
    for (final handler in _handlers) {
      if (handler.canHandle(target)) {
        handler.handle(target);
        _wasHandled = true;
        _lastTarget = null;
        return;
      }
    }
    _globalDeepLinkHandler?.handle(target);
  }

  void handleLastLinkIfAny() {
    if (_lastTarget == null || _wasHandled) return;
    dispatch(_lastTarget!);
  }

  void clear() {
    _lastTarget = null;
    _wasHandled = false;
  }
}
