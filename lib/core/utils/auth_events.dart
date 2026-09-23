import 'dart:async';

/// Fired by HTTP-layer code (e.g. [UnauthenticatedInterceptor]) when the
/// server rejects the current session. Deliberately just a bare stream —
/// no dependency on Flutter, BuildContext, or any cubit — so the layer
/// that detects this has zero coupling to how the app reacts to it.
class AuthEvents {
  AuthEvents._();

  static final sessionExpired = StreamController<void>.broadcast();
}
