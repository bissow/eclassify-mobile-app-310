import 'package:eClassify/features/auth/auth_module.dart';
import 'package:eClassify/features/auth/models/auth_provider.dart';
import 'package:eClassify/features/auth/models/auth_request.dart';
import 'package:eClassify/features/auth/models/auth_result.dart';
import 'package:eClassify/features/auth/models/user.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider, User;
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LoginState {
  const LoginState(this.provider);

  final AuthProvider? provider;
}

class LoginInitial extends LoginState {
  const LoginInitial(super.provider);
}

class LoginInProgress extends LoginState {
  const LoginInProgress(super.provider);
}

class LoginSuccess extends LoginState {
  LoginSuccess(super.provider, {required this.user, required this.token});

  final User user;
  final String token;
}

class LoginFailure extends LoginState {
  LoginFailure(super.provider, {required this.error});

  final Object error;
}

/// Firebase sign-in succeeded but the account's email was never verified.
/// The backend is never hit in this case — [EmailNotVerifiedException] is
/// thrown before [_repository.registerOrLoginRemote] so no session is
/// established.
class LoginEmailUnverified extends LoginState {
  const LoginEmailUnverified(super.provider);
}

class EmailNotVerifiedException implements Exception {
  const EmailNotVerifiedException();
}

/// A first-time social sign-in is paused pending the user's response to
/// [TermsAcceptanceDialog] — thrown to unwind out of [login] without
/// [LoginRequiresTermsAcceptance] (already emitted) being clobbered by the
/// generic failure handler below.
class _TermsAcceptancePending implements Exception {
  const _TermsAcceptancePending();
}

/// A first-time social login user (per [AuthRepository.checkSocialUserExists])
/// must accept the Terms of Service / Privacy Policy before the account is
/// created. The UI should show [TermsAcceptanceDialog] and call
/// [LoginCubit.continueAfterTermsAccepted] or
/// [LoginCubit.abortTermsAcceptance] with the result.
class LoginRequiresTermsAcceptance extends LoginState {
  const LoginRequiresTermsAcceptance(super.provider);
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial(null));

  final _repository = AuthModule.instance.repository;
  final _emailAuthService = AuthModule.instance.emailAuthService;
  final _oauthService = AuthModule.instance.oauthService;

  UserCredential? _pendingSocialCredential;

  Future<void> login(AuthRequest request) async {
    final provider = _getProvider(request);
    try {
      emit(LoginInProgress(provider));

      final result = await switch (request) {
        EmailAuthRequest req => _loginWithEmail(req),
        PhoneAuthRequest req => _loginWithPhone(req),
        GoogleAuthRequest _ => _loginWithSocial(
          provider,
          _oauthService.signInWithGoogle,
        ),
        AppleAuthRequest _ => _loginWithSocial(
          provider,
          _oauthService.signInWithApple,
        ),
      };

      await _repository.localSessionService.saveLocalUser(result.user);
      await _repository.localSessionService.saveLocalJwtToken(result.token);

      emit(LoginSuccess(provider, user: result.user, token: result.token));
    } on EmailNotVerifiedException {
      emit(LoginEmailUnverified(provider));
    } on _TermsAcceptancePending {
      // LoginRequiresTermsAcceptance was already emitted in _loginWithSocial.
    } on Exception catch (e, st) {
      Log.error('Login failed', e, st);
      emit(LoginFailure(provider, error: e));
    }
  }

  /// Resumes a social login that was paused by [LoginRequiresTermsAcceptance]
  /// after the user agreed to the Terms of Service / Privacy Policy.
  Future<void> continueAfterTermsAccepted() async {
    final credential = _pendingSocialCredential;
    final provider = state.provider;
    if (credential == null || provider == null) return;

    emit(LoginInProgress(provider));
    try {
      final result = await _repository.registerOrLoginRemote(
        firebaseId: credential.user!.uid,
        provider: provider,
        email: credential.user?.email,
        name: credential.user?.displayName,
      );

      await _repository.localSessionService.saveLocalUser(result.user);
      await _repository.localSessionService.saveLocalJwtToken(result.token);

      emit(LoginSuccess(provider, user: result.user, token: result.token));
    } on Exception catch (e, st) {
      Log.error('Login failed', e, st);
      emit(LoginFailure(provider, error: e));
    } finally {
      _pendingSocialCredential = null;
    }
  }

  /// Aborts a social login that was paused by [LoginRequiresTermsAcceptance]
  /// because the user declined — signs the half-authenticated Firebase
  /// session back out so it can't silently be reused.
  Future<void> abortTermsAcceptance() async {
    _pendingSocialCredential = null;
    await _oauthService.signOutOAuth();
    emit(const LoginInitial(null));
  }

  /// Resends the verification email to whichever account is currently
  /// signed in to Firebase — i.e. the one that just failed with
  /// [EmailNotVerifiedException], since sign-in itself already succeeded
  /// before that check ran.
  Future<void> resendVerificationEmail() {
    return _emailAuthService.sendVerificationEmail();
  }

  AuthProvider _getProvider(AuthRequest request) {
    return switch (request) {
      EmailAuthRequest _ => AuthProvider.email,
      PhoneAuthRequest _ => AuthProvider.phone,
      GoogleAuthRequest _ => AuthProvider.google,
      AppleAuthRequest _ => AuthProvider.apple,
    };
  }

  // Sign-up goes through EmailRegistrationCubit (compulsory email verification
  // flow) — this only ever signs an existing user in. Firebase stays the sole
  // password authority for email accounts (matches how password reset works),
  // so sign-in must go through it rather than hitting the backend directly.
  Future<AuthResult> _loginWithEmail(EmailAuthRequest request) async {
    assert(request.authType == AuthType.signIn);

    final credential = await _emailAuthService.signIn(
      email: request.email,
      password: request.password,
    );

    // credential.user.emailVerified can be a stale cached flag (e.g. the
    // user verified via the email link on another session) — reload first.
    final isVerified = await _emailAuthService.checkEmailVerificationStatus();
    if (!isVerified) {
      throw const EmailNotVerifiedException();
    }

    return _repository.registerOrLoginRemote(
      firebaseId: credential.user!.uid,
      provider: AuthProvider.email,
      email: request.email,
      name: credential.user?.displayName,
    );
  }

  Future<AuthResult> _loginWithPhone(PhoneAuthRequest request) {
    return _repository.loginWithPhonePassword(
      contact: request.contact,
      password: request.password,
    );
  }

  Future<AuthResult> _loginWithSocial(
    AuthProvider provider,
    Future<UserCredential> Function() signIn,
  ) async {
    final credential = await signIn();

    if (Constant.requireTermsConsent) {
      final exists = await _repository.checkSocialUserExists(
        firebaseId: credential.user!.uid,
      );

      if (!exists) {
        _pendingSocialCredential = credential;
        emit(LoginRequiresTermsAcceptance(provider));
        throw const _TermsAcceptancePending();
      }
    }

    return _repository.registerOrLoginRemote(
      firebaseId: credential.user!.uid,
      provider: provider,
      email: credential.user?.email,
      name: credential.user?.displayName,
    );
  }
}
