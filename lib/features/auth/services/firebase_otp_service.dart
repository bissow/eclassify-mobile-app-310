import 'package:eClassify/features/auth/services/otp_auth_service.dart';
import 'package:eClassify/core/models/contact.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseOtpService implements OtpAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<void> sendOtp({
    required Contact contact,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(dynamic error) onFailed,
    required void Function(dynamic credential) onAutoVerified,
    int? forceResendingToken,
  }) async {
    final code = contact.callingCode.replaceFirst('+', '');
    final fullPhoneNumber = '+$code${contact.number}';

    await _auth.verifyPhoneNumber(
      phoneNumber: fullPhoneNumber,
      timeout: Duration(seconds: Constant.otpTimeOutSecond),
      forceResendingToken: forceResendingToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        final userCredential = await _auth.signInWithCredential(credential);
        onAutoVerified(userCredential);
      },
      verificationFailed: onFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
    String? password,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(credential);
  }
}
