import 'package:eClassify/features/auth/auth_module.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LogoutState {}

class LogoutInitial extends LogoutState {}

class LoggingOut extends LogoutState {}

class LogoutSuccess extends LogoutState {}

class LogoutFailure extends LogoutState {
  LogoutFailure(this.error);

  final Object error;
}

class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit() : super(LogoutInitial());

  final _repository = AuthModule.instance.repository;
  final _oauthService = AuthModule.instance.oauthService;

  Future<void> logout() async {
    emit(LoggingOut());

    // FCM token comes from the locally persisted user, not a fresh
    // FirebaseMessaging fetch — the backend needs the token it already
    // has on record for this device/user to unregister it.
    final fcmToken = AppSession.currentUser?.fcmId ?? '';

    try {
      await _repository.remoteLogout(fcmToken: fcmToken);
    } on Exception catch (e, st) {
      // Fail-soft: still clear the local session even if the remote
      // logout call fails (e.g. no network) — don't strand the user
      // signed in locally just because the backend couldn't be told.
      Log.error('Remote logout failed', e, st);
    }

    try {
      // Fail-soft: a Google/Firebase sign-out hiccup shouldn't block
      // clearing the local session either.
      await _oauthService.signOutOAuth();
    } on Exception catch (e, st) {
      Log.error('OAuth sign-out failed', e, st);
    }

    try {
      await _repository.localSessionService.clearLocalSession();
      emit(LogoutSuccess());
    } on Exception catch (e, st) {
      Log.error('Failed to clear local session', e, st);
      emit(LogoutFailure(e));
    }
  }
}
