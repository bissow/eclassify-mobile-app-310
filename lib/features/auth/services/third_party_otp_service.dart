import 'package:eClassify/features/auth/models/auth_result.dart';
import 'package:eClassify/features/auth/models/user.dart';
import 'package:eClassify/features/auth/services/otp_auth_service.dart';
import 'package:eClassify/core/models/contact.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/log.dart';

class ThirdPartyOtpService implements OtpAuthService {
  Contact? _lastContact;

  @override
  Future<void> sendOtp({
    required Contact contact,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(dynamic error) onFailed,
    required void Function(dynamic credential) onAutoVerified,
    int? forceResendingToken,
  }) async {
    _lastContact = contact;

    try {
      await Api.get(
        url: ApiEndpoints.getTwilioOtp,
        queryParameters: {
          ApiParams.number: contact.number,
          ApiParams.countryCode: contact.callingCode,
        },
      );
      onCodeSent('', null);
    } on Exception catch (e, st) {
      Log.error('Failed to send Twilio OTP', e, st);
      onFailed(e);
    }
  }

  @override
  Future<AuthResult> verifyOtp({
    required String verificationId,
    required String smsCode,
    String? password,
  }) async {
    final response = await Api.get(
      url: ApiEndpoints.verifyTwilioOtp,
      queryParameters: {
        'number': _lastContact?.number,
        'country_code': _lastContact?.callingCode,
        'otp': smsCode,
        'password': ?password,
      },
    );

    final user = User.fromJson(response['data']);
    return (token: response['token'] as String, user: user);
  }
}
