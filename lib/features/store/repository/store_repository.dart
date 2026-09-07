import 'dart:io';
import 'package:dio/dio.dart';
import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/item/models/item.dart';
import 'package:eClassify/features/store/models/store_model.dart';
import 'package:path/path.dart' as path;

class StoreRepository {
  StoreRepository._internal();

  static final StoreRepository _instance = StoreRepository._internal();

  static StoreRepository get instance => _instance;

  Future<PaginatedResult<StoreModel>> getStores({
    double? latitude,
    double? longitude,
    num? radius,
    String? country,
    String? state,
    String? city,
    int? areaId,
    String? search,
    String? sortBy,
    int page = 1,
    int limit = 15,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (radius != null) queryParams['radius'] = radius;
      if (country != null && country.isNotEmpty) queryParams['country'] = country;
      if (state != null && state.isNotEmpty) queryParams['state'] = state;
      if (city != null && city.isNotEmpty) queryParams['city'] = city;
      if (areaId != null) queryParams['area_id'] = areaId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sort_by'] = sortBy;

      final response = await Api.get(
        url: ApiEndpoints.getStores,
        queryParameters: queryParams,
      );

      final dataList = response['data']?['data'] as List? ?? [];
      final stores = JsonHelper.parseList(
        dataList,
        StoreModel.fromJson,
      );
      final total = response['data']?['total'] as int? ?? stores.length;

      return PaginatedResult<StoreModel>(data: stores, total: total);
    } on Exception catch (e, stack) {
      Log.error('Error in getStores: $e', e, stack);
      rethrow;
    }
  }

  Future<({StoreModel store, List<Item> items})> getStoreDetail({
    String? slug,
    int? id,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (slug != null) queryParams['slug'] = slug;
      if (id != null) queryParams['id'] = id;
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;

      final response = await Api.get(
        url: ApiEndpoints.getStoreDetail,
        queryParameters: queryParams,
      );

      final responseData = response['data'] as Map<String, dynamic>;
      
      final Map<String, dynamic> storeJson = responseData['store'] is Map
          ? Map<String, dynamic>.from(responseData['store'] as Map)
          : responseData;
      final store = StoreModel.fromJson(storeJson);

      List rawItems = [];
      if (responseData['items'] is Map && (responseData['items'] as Map)['data'] is List) {
        rawItems = (responseData['items'] as Map)['data'] as List;
      } else if (responseData['items'] is List) {
        rawItems = responseData['items'] as List;
      } else if (storeJson['items'] is List) {
        rawItems = storeJson['items'] as List;
      }

      final items = JsonHelper.parseList(
        rawItems,
        Item.fromJson,
      );

      return (store: store, items: items);
    } on Exception catch (e, stack) {
      Log.error('Error in getStoreDetail: $e', e, stack);
      rethrow;
    }
  }

  Future<StoreModel?> getMyStore() async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getMyStore,
      );

      if (response['data'] == null) {
        return null;
      }

      final data = response['data'] as Map<String, dynamic>;
      if (data.containsKey('has_store') && data['has_store'] == false) {
        return null;
      }

      final Map<String, dynamic> storeData = data['store'] is Map
          ? Map<String, dynamic>.from(data['store'] as Map)
          : data;

      return StoreModel.fromJson(storeData);
    } on Exception catch (e, stack) {
      Log.error('Error in getMyStore: $e', e, stack);
      rethrow;
    }
  }

  Future<StoreModel> setupStore({
    required Map<String, dynamic> fields,
    File? logoFile,
    File? bannerFile,
  }) async {
    try {
      final formDataMap = Map<String, dynamic>.from(fields);

      if (logoFile != null) {
        formDataMap['logo'] = await MultipartFile.fromFile(
          logoFile.path,
          filename: path.basename(logoFile.path),
        );
      }

      if (bannerFile != null) {
        formDataMap['banner'] = await MultipartFile.fromFile(
          bannerFile.path,
          filename: path.basename(bannerFile.path),
        );
      }

      final response = await Api.post(
        url: ApiEndpoints.setupStore,
        parameter: formDataMap,
      );

      final data = response['data'] as Map<String, dynamic>;
      final Map<String, dynamic> storeData = data['store'] is Map
          ? Map<String, dynamic>.from(data['store'] as Map)
          : data;

      return StoreModel.fromJson(storeData);
    } on Exception catch (e, stack) {
      Log.error('Error in setupStore: $e', e, stack);
      rethrow;
    }
  }

  Future<bool> toggleStoreStatus() async {
    try {
      final response = await Api.post(
        url: ApiEndpoints.toggleStoreStatus,
      );

      return !(response['error'] as bool? ?? false);
    } on Exception catch (e, stack) {
      Log.error('Error in toggleStoreStatus: $e', e, stack);
      rethrow;
    }
  }
}
