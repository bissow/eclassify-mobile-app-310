import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/custom_fields/models/custom_field.dart';

class CustomFieldsRepository {
  CustomFieldsRepository._internal();

  static final CustomFieldsRepository _instance =
      CustomFieldsRepository._internal();

  static CustomFieldsRepository get instance => _instance;

  Future<List<CustomField>> getCustomFields({
    required int categoryId,
    bool isForFilter = false,
  }) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getCustomFields,
        queryParameters: {
          ApiParams.categoryId: categoryId,
          if (isForFilter) 'filter': true,
        },
      );

      final fields = JsonHelper.parseList(
        response['data'] as List?,
        CustomField.parse,
      );

      return fields;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
