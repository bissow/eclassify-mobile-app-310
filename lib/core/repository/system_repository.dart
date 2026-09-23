import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/models/currency.dart';
import 'package:eClassify/core/models/system_settings.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/utils/log.dart';

class SystemRepository {
  SystemRepository._();

  static final _instance = SystemRepository._();

  static SystemRepository get instance => _instance;

  Future<SystemSettings> getSystemSettings() async {
    try {
      final response = await Api.get(url: ApiEndpoints.getSystemSettings);
      return JsonHelper.parseObject(
        response['data'] as Json,
        SystemSettings.fromJson,
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<void> sendUserQuery({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      await Api.post(
        url: ApiEndpoints.contactUs,
        parameter: {
          ApiParams.name: name,
          ApiParams.email: email,
          'subject': subject,
          'message': message,
        },
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<List<Currency>> getCurrencies() async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getCurrencies,
        queryParameters: {
          'country': ?AppSession.currentLocation?.country?.canonical,
        },
      );
      return JsonHelper.parseList(response['data'] as List?, Currency.fromJson);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<Json> getLanguage({required String languageCode}) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getLanguage,
        queryParameters: {
          ApiParams.languageCode: languageCode.toLowerCase(),
          ApiParams.type: 'app',
        },
      );
      return response['data'] as Json;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
