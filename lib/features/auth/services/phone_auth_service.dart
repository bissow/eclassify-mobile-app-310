import 'dart:io';

import 'package:eClassify/features/auth/models/auth_provider.dart';
import 'package:eClassify/features/auth/models/auth_result.dart';
import 'package:eClassify/features/auth/models/user.dart';
import 'package:eClassify/core/models/contact.dart';
import 'package:eClassify/core/network/api.dart';

class PhoneAuthService {
  Future<AuthResult> signInWithPhonePassword({
    required Contact contact,
    required String password,
    String? fcmId,
  }) async {
    final response = await Api.post(
      url: ApiEndpoints.login,
      parameter: {
        ApiParams.mobile: contact.number,
        'password': password,
        ApiParams.countryCode: contact.callingCode,
        ApiParams.regionCode: contact.regionCode,
        ApiParams.platformType: Platform.operatingSystem,
        ApiParams.type: AuthProvider.phone.raw,
        'is_login': '1',
        ApiParams.fcmId: ?fcmId,
      },
    );

    final user = User.fromJson(response['data']);
    return (token: response['token'] as String, user: user);
  }
}
