import 'package:eClassify/features/auth/auth_module.dart';
import 'package:eClassify/features/auth/cubits/otp_flow_state.dart';
import 'package:eClassify/features/auth/models/auth_provider.dart';
import 'package:eClassify/features/auth/models/auth_result.dart';
import 'package:eClassify/core/models/contact.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/enums/otp_provider_type.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User, AuthProvider;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

/// Shared OTP send/resend/verify mechanics for phone-based flows. Subclasses
/// only need [failureState] (their own failure type) and [onOtpVerified] —
/// deciding what "success" means for them: [OtpVerificationCubit] logs the
/// user in, [PhonePasswordResetCubit] deliberately never persists a session.
abstract class BaseOtpCubit extends Cubit<OtpFlowState> {
  BaseOtpCubit() : super(OtpFlowInitial());

  @protected
  final repository = AuthModule.instance.repository;
  final _firebaseOtpService = AuthModule.instance.firebaseOtpService;
  final _thirdPartyOtpService = AuthModule.instance.thirdPartyOtpService;

  final _provider = Constant.systemSettings.otpProvider;

  // To display in the OTP verification UI.
  String? _lastFormattedNumber;

  String get formattedNumber => _lastFormattedNumber ?? '';

  @protected
  Contact? lastContact;
  @protected
  String? lastPassword;
  int? _lastResendToken;

  @protected
  OtpFlowState failureState(Object error);

  /// Called once a token has been obtained, via either an explicit
  /// [verifyOtp] call or Firebase's own auto-verification. Implementations
  /// decide whether/what to persist.
  @protected
  Future<void> onOtpVerified(AuthResult result);

  Future<void> sendOtp({
    required Contact contact,
    String? formattedNumber,
    String? password,
  }) async {
    _lastFormattedNumber = formattedNumber;
    lastContact = contact;
    lastPassword = password;

    await _sendOtp();
  }

  /// Resends to the number/country cached from the last [sendOtp] call,
  /// carrying forward the last resend token so Firebase can issue a fresh
  /// SMS on the same verification session.
  Future<void> resendOtp() async {
    await _sendOtp(resendToken: _lastResendToken);
  }

  Future<void> _sendOtp({int? resendToken}) async {
    emit(OtpFlowSending());

    final service = _provider == OtpProviderType.firebase
        ? _firebaseOtpService
        : _thirdPartyOtpService;

    await service.sendOtp(
      contact: lastContact!,
      forceResendingToken: resendToken,
      onCodeSent: (verificationId, token) {
        _lastResendToken = token;
        emit(OtpFlowSent(verificationId: verificationId, resendToken: token));
      },
      onFailed: (error) {
        Log.error('OTP sending failed', error, null);
        emit(failureState(error));
      },
      onAutoVerified: (credential) async {
        try {
          await _finishVerification(credential as UserCredential);
        } on Exception catch (e, st) {
          Log.error('Auto-verified OTP failed', e, st);
          emit(failureState(e));
        }
      },
    );
  }

  Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      emit(OtpFlowVerifying());

      final service = _provider == OtpProviderType.firebase
          ? _firebaseOtpService
          : _thirdPartyOtpService;

      final result = await service.verifyOtp(
        verificationId: verificationId,
        smsCode: smsCode,
        password: lastPassword,
      );

      await _finishVerification(result);
    } on Exception catch (e, st) {
      Log.error('OTP verification failed', e, st);
      emit(failureState(e));
    }
  }

  Future<void> _finishVerification(dynamic result) async {
    final AuthResult authResult;
    if (result is UserCredential) {
      authResult = await repository.registerOrLoginRemote(
        firebaseId: result.user!.uid,
        provider: AuthProvider.phone,
        contact: lastContact,
        password: lastPassword,
        isLogin: false,
      );
    } else {
      authResult = result as AuthResult;
    }

    await onOtpVerified(authResult);
  }
}
