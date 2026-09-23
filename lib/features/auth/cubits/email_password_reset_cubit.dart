import 'package:eClassify/features/auth/auth_module.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class EmailPasswordResetState {}

class EmailPasswordResetInitial extends EmailPasswordResetState {}

class EmailPasswordResetInProgress extends EmailPasswordResetState {}

class EmailPasswordResetSuccess extends EmailPasswordResetState {}

class EmailPasswordResetFailure extends EmailPasswordResetState {
  EmailPasswordResetFailure(this.error);

  final Object error;
}

/// Sends a Firebase password-reset email. No app-side session/JWT involved —
/// Firebase owns email accounts' passwords entirely, and emails the reset
/// link directly, so the backend is never involved here.
class EmailPasswordResetCubit extends Cubit<EmailPasswordResetState> {
  EmailPasswordResetCubit() : super(EmailPasswordResetInitial());

  final _emailAuthService = AuthModule.instance.emailAuthService;

  Future<void> resetPassword({required String email}) async {
    try {
      emit(EmailPasswordResetInProgress());
      await _emailAuthService.resetPassword(email: email);
      emit(EmailPasswordResetSuccess());
    } on Exception catch (e, st) {
      Log.error('Failed to send password reset email', e, st);
      emit(EmailPasswordResetFailure(e));
    }
  }
}
