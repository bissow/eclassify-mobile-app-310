import 'package:eClassify/features/auth/cubits/base_otp_cubit.dart';
import 'package:eClassify/features/auth/cubits/otp_flow_state.dart';
import 'package:eClassify/features/auth/models/auth_result.dart';
import 'package:eClassify/core/utils/log.dart';

/// OTP-stage failure only (send/resend/verify) — kept distinct from
/// [PhoneResetFailure] so PhonePasswordResetOtpScreen and
/// SetNewPasswordScreen, which can both be mounted at once (stacked
/// routes) while sharing this one cubit, only react to the failure meant
/// for them.
class PhoneResetOtpFailure extends OtpFlowState {
  PhoneResetOtpFailure(this.error);

  final Object error;
}

/// OTP verified — a token has been obtained (kept in-memory only, never
/// persisted) and the flow is ready for the new-password step.
class PhoneResetOtpVerified extends OtpFlowState {}

class PhoneResetSettingPassword extends OtpFlowState {}

class PhoneResetSuccess extends OtpFlowState {}

class PhoneResetFailure extends OtpFlowState {
  PhoneResetFailure(this.error);

  final Object error;
}

/// Handles the phone forgot-password journey: verify phone ownership via OTP,
/// then submit a new password. Deliberately never persists a session — the
/// token obtained during OTP verification is held only in-memory
/// ([_jwtToken]) and is never written to LocalSessionService/AppSession, so
/// closing the app mid-flow leaves the user signed out, not silently logged
/// in under the old password.
class PhonePasswordResetCubit extends BaseOtpCubit {
  // In-memory only — never persisted via LocalSessionService/AppSession.
  String? _jwtToken;

  @override
  OtpFlowState failureState(Object error) => PhoneResetOtpFailure(error);

  @override
  Future<void> onOtpVerified(AuthResult result) async {
    _jwtToken = result.token;
    emit(PhoneResetOtpVerified());
  }

  Future<void> resetPassword({required String newPassword}) async {
    try {
      emit(PhoneResetSettingPassword());

      await repository.resetPasswordWithPhone(
        contact: lastContact!,
        newPassword: newPassword,
        jwtToken: _jwtToken!,
      );

      _jwtToken = null;
      emit(PhoneResetSuccess());
    } on Exception catch (e, st) {
      Log.error('Failed to reset password', e, st);
      emit(PhoneResetFailure(e));
    }
  }
}
