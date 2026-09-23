import 'dart:async';

import 'package:dio/dio.dart';
import 'package:eClassify/core/utils/auth_events.dart';

class UnauthenticatedInterceptor extends Interceptor {
  bool _isHandling = false;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 && !_isHandling) {
      _isHandling = true;
      AuthEvents.sessionExpired.add(null);
      // Reset on the next microtask so a later, independent 401 (e.g.
      // after logging back in) can still fire this again.
      scheduleMicrotask(() => _isHandling = false);
    }
    handler.next(err);
  }
}
