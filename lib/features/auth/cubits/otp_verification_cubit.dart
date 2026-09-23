import 'package:eClassify/features/auth/cubits/base_otp_cubit.dart';
import 'package:eClassify/features/auth/cubits/otp_flow_state.dart';
import 'package:eClassify/features/auth/models/auth_result.dart';
import 'package:eClassify/features/auth/models/user.dart';

class OtpVerificationSuccess extends OtpFlowState {
  OtpVerificationSuccess({required this.user, required this.token});

  final User user;
  final String token;
}

class OtpVerificationFailure extends OtpFlowState {
  OtpVerificationFailure(this.error);

  final Object error;
}

class OtpVerificationCubit extends BaseOtpCubit {
  @override
  OtpFlowState failureState(Object error) => OtpVerificationFailure(error);

  @override
  Future<void> onOtpVerified(AuthResult result) async {
    await repository.localSessionService.saveLocalUser(result.user);
    await repository.localSessionService.saveLocalJwtToken(result.token);
    emit(OtpVerificationSuccess(user: result.user, token: result.token));
  }
}
