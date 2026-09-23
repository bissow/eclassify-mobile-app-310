import 'package:dio/dio.dart';
import 'package:eClassify/features/custom_fields/models/custom_field.dart';
import 'package:eClassify/features/custom_fields/models/custom_field_value.dart';
import 'package:eClassify/core/models/file_resource.dart';
import 'package:eClassify/features/verification/models/verification_request.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/utils/log.dart';

typedef _Fields = Map<String, dynamic>;
typedef _FieldFiles = Map<String, MultipartFile>;

class UserVerificationRepository {
  UserVerificationRepository._internal();

  static final UserVerificationRepository _instance =
      UserVerificationRepository._internal();

  static UserVerificationRepository get instance => _instance;

  Future<VerificationRequest> getVerificationRequest() async {
    try {
      final response = await Api.get(url: ApiEndpoints.getVerificationRequest);
      return VerificationRequest.fromJson(response['data'] as Json);
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  Future<List<CustomField>> getUserVerificationFields() async {
    try {
      final response = await Api.get(url: ApiEndpoints.getVerificationField);

      final fields = JsonHelper.parseList(
        response['data'] as List?,
        CustomField.parse,
      );

      return fields;
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  Future<String> submitVerificationDetails({
    required Map<int, CustomFieldValue> data,
  }) async {
    try {
      final _processedData = await _processFields(data);

      final response = await Api.post(
        url: ApiEndpoints.sendVerificationRequest,
        parameter: {
          'verification_field': _processedData.fields,
          'verification_field_files': _processedData.files,
        },
      );

      return response['message'] as String;
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  Future<({_Fields fields, _FieldFiles files})> _processFields(
    Map<int, CustomFieldValue> raw,
  ) async {
    final fields = <String, dynamic>{};
    final files = <String, MultipartFile>{};

    for (final entry in raw.entries) {
      final fieldValue = entry.value;
      if (fieldValue.value case LocalFileResource r) {
        files[entry.key.toString()] = MultipartFile.fromFileSync(r.filePath);
      } else {
        fields[entry.key.toString()] = fieldValue.value;
      }
    }

    return (fields: fields, files: files);
  }
}
