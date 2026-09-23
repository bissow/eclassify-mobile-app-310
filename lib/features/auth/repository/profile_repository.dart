import 'package:dio/dio.dart';
import 'package:eClassify/features/auth/models/user.dart';
import 'package:eClassify/core/network/api.dart';

class ProfileRepository {
  Future<({User user, String? message})> getUserProfile() async {
    final response = await Api.get(url: ApiEndpoints.userProfile);

    final user = User.fromJson(response['data'] as Map<String, dynamic>);
    return (user: user, message: response['message'] as String?);
  }

  Future<({User user, String? message})> updateUserProfile(
    User user, {
    String? profileImagePath,
  }) async {
    final parameters = <String, dynamic>{
      ApiParams.name: user.name,
      ApiParams.email: user.email,
      ApiParams.address: ?user.address,
      ApiParams.fcmId: ?user.fcmId,
      ApiParams.notification: user.notificationsEnabled ? 1 : 0,
      ApiParams.mobile: user.contact.number,
      ApiParams.countryCode: user.contact.callingCode,
      ApiParams.regionCode: user.contact.regionCode,
      ApiParams.personalDetail: user.showPersonalDetails ? 1 : 0,
    };

    if (profileImagePath != null) {
      parameters['profile'] = await MultipartFile.fromFile(profileImagePath);
    }

    final response = await Api.post(
      url: ApiEndpoints.updateProfile,
      parameter: parameters,
    );

    final updatedUser = User.fromJson(response['data'] as Map<String, dynamic>);
    return (user: updatedUser, message: response['message'] as String?);
  }
}
