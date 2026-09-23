import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/utils/log.dart';

class FavoriteRepository {
  FavoriteRepository._internal();

  static final FavoriteRepository _instance = FavoriteRepository._internal();

  static FavoriteRepository get instance => _instance;

  Future<void> toggleFavorite({required int itemId}) async {
    try {
      await Api.post(
        url: ApiEndpoints.manageFavourite,
        parameter: {ApiParams.itemId: itemId},
      );
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  Future<PaginatedResult<ItemPreview>> getFavoriteItems({int page = 1}) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getFavoriteItem,
        queryParameters: {ApiParams.page: page},
      );
      final items = JsonHelper.parseList<ItemPreview>(
        response['data']['data'] as List?,
        ItemPreview.fromJson,
      );
      final total = response['data']['total'] as int;

      return PaginatedResult<ItemPreview>(data: items, total: total);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
