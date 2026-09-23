import 'dart:async';

import 'package:eClassify/features/auth/auth_module.dart';
import 'package:eClassify/features/auth/models/user.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/utils/auth_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthSessionState {}

class AuthSessionInitial extends AuthSessionState {}

enum SessionEndReason { userInitiated, expired }

class Unauthenticated extends AuthSessionState {
  Unauthenticated({this.reason = SessionEndReason.userInitiated});

  final SessionEndReason reason;
}

class Authenticated extends AuthSessionState {
  final User user;

  Authenticated({required this.user});
}

/// A fresh sign-up that still has to go through the profile screen.
/// Only ever emitted by [completeSignUp]; never derived from stored data, so
/// a relaunch after killing the app there lands on the main screen (the
/// account already carries a `guest_*` name).
class ProfileSetupPending extends AuthSessionState {
  final User user;

  ProfileSetupPending({required this.user});
}

class AuthSessionCubit extends Cubit<AuthSessionState> {
  AuthSessionCubit() : super(AuthSessionInitial()) {
    checkCurrentSession();
    _authEventsSubscription = AuthEvents.sessionExpired.stream.listen(
      (_) => forceLogout(),
    );
  }

  late final StreamSubscription<void> _authEventsSubscription;

  void checkCurrentSession() {
    final user = AppSession.currentUser;
    if (user == null) {
      emit(Unauthenticated());
    } else {
      emit(Authenticated(user: user));
    }
  }

  void updateSession(User user) {
    emit(Authenticated(user: user));
  }

  /// Sign-up succeeded; offer the profile screen before entering the app.
  void completeSignUp(User user) {
    emit(ProfileSetupPending(user: user));
  }

  void clearSession() async {
    await AuthModule.instance.localSessionService.clearLocalSession();
    emit(Unauthenticated());
  }

  Future<void> forceLogout() async {
    if (state is Unauthenticated) return;
    await AuthModule.instance.localSessionService.clearLocalSession();
    emit(Unauthenticated(reason: SessionEndReason.expired));
  }

  @override
  Future<void> close() {
    _authEventsSubscription.cancel();
    return super.close();
  }
}
