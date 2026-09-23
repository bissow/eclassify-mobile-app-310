import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/core/models/user_preview.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/utils/log.dart';

class ItemBuyerRepository {
  ItemBuyerRepository._internal();

  static final ItemBuyerRepository _instance = ItemBuyerRepository._internal();

  static ItemBuyerRepository get instance => _instance;

  // NOTE: Technically this should be a paginated API with search
  // but since it isn't we keep implementation as paginated in case of
  // future implementation
  Future<PaginatedResult<UserPreview>> getBuyerList({
    required int itemId,
    required bool isJobItem,
    int page = 1,
  }) async {
    try {
      final api = isJobItem
          ? ApiEndpoints.getJobApplications
          : ApiEndpoints.getItemBuyerList;
      final response = await Api.get(
        url: api,
        queryParameters: {ApiParams.itemId: itemId, ApiParams.page: page},
      );
      final users = JsonHelper.parseList(
        response['data'] as List?,
        UserPreview.fromJson,
      );
      final total = users.length;
      return PaginatedResult(data: users, total: total);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
