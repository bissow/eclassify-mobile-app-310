import 'package:eClassify/core/models/contact.dart';

abstract class OtpAuthService {
  Future<void> sendOtp({
    required Contact contact,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(dynamic error) onFailed,
    required void Function(dynamic credential) onAutoVerified,
    int? forceResendingToken,
  });

  Future<dynamic> verifyOtp({
    required String verificationId,
    required String smsCode,
    String? password,
  });
}
