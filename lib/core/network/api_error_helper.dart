import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Central place to turn any caught [Exception]/[Error] into a localized,
/// user-facing message. Dispatches by runtime type to a private resolver
/// per exception source; unrecognized types fall back to a generic message.
class ApiErrorHelper {
  const ApiErrorHelper._();

  /// Whether [exception] is the server rejecting the current session. Screens
  /// use this to sit tight while `AuthSessionCubit` clears the dead token,
  /// instead of surfacing a 401 as a generic failure the user can only retry
  /// into. Detection is kept in sync with `UnauthenticatedInterceptor`.
  static bool isUnauthenticated(Object? exception) =>
      exception is DioException && exception.response?.statusCode == 401;

  static String errorMessageFromException(
    BuildContext context,
    Object exception,
  ) {
    switch (exception) {
      case FirebaseAuthException e:
        return _FirebaseAuthExceptionMessages.resolve(context, e);
      case GoogleSignInException e:
        return _GoogleAuthExceptionMessages.resolve(context, e);
      case SignInWithAppleAuthorizationException e:
        return _AppleAuthExceptionMessages.resolve(context, e);
      case DioException e:
        return _DioExceptionMessages.resolve(context, e);
      case ApiException e:
        return _ApiExceptionMessages.resolve(context, e);
      default:
        return 'somethingWentWrongTitle'.translate(context);
    }
  }
}

class _FirebaseAuthExceptionMessages {
  const _FirebaseAuthExceptionMessages._();

  static final Map<String, String> _keyByCode = {
    'network-request-failed': 'networkRequestFailed',
    'app-not-authorized': 'appNotAuthorized',
    'no-internet': 'checkNetwork',
    'email-already-in-use': 'emailAlreadyInUse',
    'wrong-password': 'wrongPassword',
    'user-not-found': 'emailNotRegistered',
    'invalid-email': 'invalidEmail',
    'invalid-phone-number': 'invalidPhoneNumber',
    'invalid-verification-code': 'invalidVerificationCode',
    'session-expired': 'sessionExpired',
    'too-many-requests': 'tooManyRequests',
    'user-disabled': 'userDisabled',
    'operation-not-allowed': 'operationNotAllowed',
  };

  static String resolve(BuildContext context, FirebaseAuthException e) {
    final key = _keyByCode[e.code] ?? 'somethingWentWrongTitle';
    return key.translate(context);
  }
}

class _GoogleAuthExceptionMessages {
  const _GoogleAuthExceptionMessages._();

  static String resolve(BuildContext context, GoogleSignInException e) {
    final key = switch (e.code) {
      GoogleSignInExceptionCode.canceled => 'signInCancelled',
      GoogleSignInExceptionCode.interrupted => 'checkNetwork',
      GoogleSignInExceptionCode.uiUnavailable => 'somethingWentWrongTitle',
      _ => 'somethingWentWrongTitle',
    };
    return key.translate(context);
  }
}

class _AppleAuthExceptionMessages {
  const _AppleAuthExceptionMessages._();

  static String resolve(
    BuildContext context,
    SignInWithAppleAuthorizationException e,
  ) {
    final key = switch (e.code) {
      AuthorizationErrorCode.canceled => 'signInCancelled',
      AuthorizationErrorCode.notHandled => 'somethingWentWrongTitle',
      AuthorizationErrorCode.invalidResponse => 'somethingWentWrongTitle',
      AuthorizationErrorCode.notInteractive => 'somethingWentWrongTitle',
      AuthorizationErrorCode.failed => 'somethingWentWrongTitle',
      AuthorizationErrorCode.unknown => 'somethingWentWrongTitle',
      _ => 'somethingWentWrongTitle',
    };
    return key.translate(context);
  }
}

class _DioExceptionMessages {
  const _DioExceptionMessages._();

  static String resolve(BuildContext context, DioException e) {
    return switch ((e.error, e.type)) {
      (SocketException(), DioExceptionType.connectionError) =>
        'noInternetErrorMessage'.translate(context),
      (
        _,
        DioExceptionType.connectionTimeout ||
            DioExceptionType.receiveTimeout ||
            DioExceptionType.sendTimeout,
      ) =>
        'connectionTimedOut'.translate(context),
      (_, DioExceptionType.badResponse) => 'somethingWentWrongTitle'.translate(
        context,
      ),
      (_, _) => 'noInternetErrorMessage'.translate(context),
    };
  }
}

class _ApiExceptionMessages {
  const _ApiExceptionMessages._();

  static String resolve(BuildContext context, ApiException e) {
    final message = e.errorMessage?.toString();
    if (message.isNullOrEmpty) {
      return 'somethingWentWrongTitle'.translate(context);
    }
    return message!;
  }
}
