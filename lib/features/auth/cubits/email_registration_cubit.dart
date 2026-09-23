import 'package:eClassify/features/auth/auth_module.dart';
import 'package:eClassify/features/auth/models/auth_provider.dart';
import 'package:eClassify/features/auth/models/user.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User, AuthProvider;
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class EmailRegistrationState {}

class EmailRegistrationInitial extends EmailRegistrationState {}

class EmailRegistrationInProgress extends EmailRegistrationState {}

class EmailVerificationSent extends EmailRegistrationState {}

class EmailVerificationPending extends EmailRegistrationState {}

class EmailRegistrationSuccess extends EmailRegistrationState {
  EmailRegistrationSuccess({required this.user, required this.token});

  final User user;
  final String token;
}

class EmailRegistrationFailure extends EmailRegistrationState {
  EmailRegistrationFailure(this.error);

  final Object error;
}

/// Handles email/password sign-up, which requires a compulsory email
/// verification step before the account is considered registered.
class EmailRegistrationCubit extends Cubit<EmailRegistrationState> {
  EmailRegistrationCubit() : super(EmailRegistrationInitial());

  final _repository = AuthModule.instance.repository;
  final _emailAuthService = AuthModule.instance.emailAuthService;

  String? _lastEmail;

  Future<void> signUp({required String email, required String password}) async {
    try {
      emit(EmailRegistrationInProgress());

      _lastEmail = email;

      try {
        await _emailAuthService.signUp(email: email, password: password);
      } on FirebaseAuthException catch (e) {
        if (e.code != 'email-already-in-use') rethrow;
        // Account already exists from a prior attempt (e.g. app was closed
        // right after creation) — sign in instead of failing outright.
        await _emailAuthService.signIn(email: email, password: password);
      }

      final isVerified = await _emailAuthService.checkEmailVerificationStatus();
      if (isVerified) {
        // Handles: user closed the app, verified via the email link, and
        // came back to tap sign-up again.
        await _completeRegistration();
        return;
      }

      await _emailAuthService.sendVerificationEmail();
      emit(EmailVerificationSent());
    } on Exception catch (e, st) {
      Log.error('Email sign-up failed', e, st);
      emit(EmailRegistrationFailure(e));
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await _emailAuthService.sendVerificationEmail();
      emit(EmailVerificationSent());
    } on Exception catch (e, st) {
      Log.error('Failed to resend verification email', e, st);
      emit(EmailRegistrationFailure(e));
    }
  }

  Future<void> checkEmailVerification() async {
    try {
      final isVerified = await _emailAuthService.checkEmailVerificationStatus();
      if (!isVerified) {
        emit(EmailVerificationPending());
        return;
      }

      emit(EmailRegistrationInProgress());

      await _completeRegistration();
    } on Exception catch (e, st) {
      Log.error('Failed to check email verification status', e, st);
      emit(EmailRegistrationFailure(e));
    }
  }

  Future<void> _completeRegistration() async {
    final result = await _repository.registerOrLoginRemote(
      firebaseId: FirebaseAuth.instance.currentUser!.uid,
      provider: AuthProvider.email,
      email: _lastEmail,
      isLogin: false,
    );

    await _repository.localSessionService.saveLocalUser(result.user);
    await _repository.localSessionService.saveLocalJwtToken(result.token);

    emit(EmailRegistrationSuccess(user: result.user, token: result.token));
  }
}
