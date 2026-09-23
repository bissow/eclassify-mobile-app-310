/// Shared states for the send/resend/verify mechanics common to every
/// [BaseOtpCubit] subclass. Each cubit's own terminal states (success,
/// failure) extend this directly too, so a single state type can be used
/// per cubit — see OtpVerificationCubit/PhonePasswordResetCubit.
abstract class OtpFlowState {}

class OtpFlowInitial extends OtpFlowState {}

class OtpFlowSending extends OtpFlowState {}

class OtpFlowSent extends OtpFlowState {
  OtpFlowSent({required this.verificationId, this.resendToken});

  final String verificationId;
  final int? resendToken;
}

class OtpFlowVerifying extends OtpFlowState {}
