import 'dart:io';

import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:eClassify/app/config/app_config.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/network/network_request_interceptor.dart';
import 'package:eClassify/core/network/unauthenticated_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_debug_logger/flutter_debug_logger.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

export 'api_endpoints.dart';
export 'api_params.dart';

class ApiException implements Exception {
  ApiException(this.errorMessage);

  final String? errorMessage;

  @override
  String toString() {
    return errorMessage ?? 'ApiException';
  }
}

class Api {
  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  static final String _baseUrl = () {
    // Start with the compile-time host URL
    var url = AppConfig.hostUrl.trim();

    // Remove any trailing slashes
    url = url.replaceAll(RegExp(r'/+$'), '');

    // Append the correct '/api/' suffix
    return '$url/api/';
  }();

  static String get baseUrl => _baseUrl;

  static String _uniqueKey = Uuid().v4();

  static late final CacheOptions _cacheOptions;
  static late final Dio _dio;

  static Future<void> init() async {
    final internalPath = await getApplicationSupportDirectory();

    _cacheOptions = CacheOptions(store: HiveCacheStore(internalPath.path));

    _dio = Dio()
      ..interceptors.addAll([
        NetworkRequestInterceptor(),
        UnauthenticatedInterceptor(),
        if (kReleaseMode) DioCacheInterceptor(options: _cacheOptions),
        CurlLoggerDioInterceptor(printOnSuccess: true),
        FlutterDebugLogInterceptor(
          generateCurl: true,
          logResponseBody: true,
          logRequestBody: true,
        ),
      ]);
  }

  static Map<String, dynamic> headers({bool addContentLanguage = true}) {
    final token = AppSession.jwtToken;
    final headersMap = <String, dynamic>{
      if (token != null) "Authorization": "Bearer $token",
      "Accept": "application/json",
      if (addContentLanguage)
        "Content-Language": AppSession.currentLanguageCode.toLowerCase(),
      // A unique identity for unauthenticated users to seed the random generation in APIs
      if (!AppSession.isAuthenticated) "x-seed-key": _uniqueKey,
    };

    return headersMap;
  }

  static Future<Json> post({
    required String url,
    Json? parameter,
    Options? options,
    ProgressCallback? onSendProgress,
    // In some use-cases, the API's error field returns true but
    // we require to parse the data present inside the data parameter for further
    // processing the app. Hence, this parameter bypasses that default check and
    // returns the result as-is.
    //
    // Note: This does not by pass the app level exceptions
    bool catchApiError = true,
  }) async {
    return _guard(() async {
      final formData = FormData.fromMap(
        parameter ?? {},
        ListFormat.multiCompatible,
      );

      final response = await _dio.post(
        '$_baseUrl$url',
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          contentType: "multipart/form-data",
          headers: headers()..addAll(options?.headers ?? {}),
        ),
      );

      var resp = response.data;

      if (resp is Map && (resp['error'] ?? false) && catchApiError) {
        throw ApiException(resp['message'] as String?);
      }

      return Map.from(resp);
    });
  }

  static Future<Map<String, dynamic>> delete({
    required String url,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _guard(() async {
      final response = await _dio.delete(
        '$_baseUrl$url',
        queryParameters: queryParameters,
        options: Options(headers: headers()),
      );

      final resp = response.data;
      if (resp is Map && resp['error'] == true) {
        throw ApiException(resp['message'] as String?);
      }
      return Map.from(resp);
    });
  }

  static Future<Map<String, dynamic>> get({
    required String url,
    Map<String, dynamic>? queryParameters,
    bool addContentLanguage = true,
    bool catchApiError = true,
  }) async {
    return _guard(() async {
      final response = await _dio.get(
        '$_baseUrl$url',
        queryParameters: queryParameters,
        options: Options(
          headers: headers(addContentLanguage: addContentLanguage),
        ),
      );

      final resp = response.data;
      if (resp is Map && resp['error'] == true && catchApiError) {
        throw ApiException(resp['message'] as String?);
      }
      return Map.from(resp);
    });
  }

  static Future<String> getRaw({
    required String url,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _guard(() async {
      final response = await _dio.get(
        '$_baseUrl$url',
        queryParameters: queryParameters,
        options: Options(headers: headers(), responseType: ResponseType.plain),
      );

      return response.data.toString();
    });
  }

  static Future<void> download({
    required String url,
    required String savePath,
    CancelToken? cancelToken,
    ValueChanged<double>? onUpdate,
  }) async {
    return _guard(() async {
      await _dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        options: Options(headers: {HttpHeaders.acceptEncodingHeader: '*'}),
        onReceiveProgress: onUpdate != null
            ? (count, total) {
                final percentage = (count / total) * 100;
                onUpdate(percentage < 0.0 ? 99.0 : percentage);
              }
            : null,
      );
    });
  }

  static Future<Response> head({
    required String url,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _guard(() async {
      final response = await _dio.head(url, queryParameters: queryParameters);
      return response;
    });
  }
}
