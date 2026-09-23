import 'dart:io';
import 'package:dio/dio.dart';
import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/store/models/seller_qr_model.dart';
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

  Future<({StoreModel store, List<ItemPreview> items})> getStoreDetail({
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
        ItemPreview.fromJson,
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

  Future<({
    StoreModel store,
    List<ItemPreview> items,
    LocationWarningModel locationWarning,
    List<Map<String, dynamic>> categories,
    int total,
    SellerQrCodeModel? qrCode,
  })> getStoreByQr({
    required String identifier,
    double? latitude,
    double? longitude,
    String? search,
    int? categoryId,
    String? sortBy,
    int page = 1,
    int limit = 16,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sort_by'] = sortBy;

      final response = await Api.get(
        url: '${ApiEndpoints.sellerQrStore}/$identifier',
        queryParameters: queryParams,
      );

      final responseData = response['data'] as Map<String, dynamic>;
      final Map<String, dynamic> storeJson = responseData['store'] is Map
          ? Map<String, dynamic>.from(responseData['store'] as Map)
          : {};
      final store = StoreModel.fromJson(storeJson);

      final locationWarningJson = responseData['location_warning'] is Map
          ? Map<String, dynamic>.from(responseData['location_warning'] as Map)
          : <String, dynamic>{};
      final locationWarning = LocationWarningModel.fromJson(locationWarningJson);

      List rawItems = [];
      int totalItems = 0;
      if (responseData['items'] is Map) {
        final itemsMap = responseData['items'] as Map;
        final dataField = itemsMap['data'];
        if (dataField is List) {
          rawItems = dataField;
        } else if (dataField is Map) {
          rawItems = [dataField];
        }
        totalItems = itemsMap['total'] as int? ?? rawItems.length;
      } else if (responseData['items'] is List) {
        rawItems = responseData['items'] as List;
        totalItems = rawItems.length;
      }

      final items = JsonHelper.parseList(
        rawItems,
        ItemPreview.fromJson,
      );

      final List rawCategories = responseData['categories'] as List? ?? [];
      final categories = rawCategories.map((c) => Map<String, dynamic>.from(c as Map)).toList();

      SellerQrCodeModel? qrCode;
      if (responseData['qr_code'] is Map) {
        qrCode = SellerQrCodeModel.fromJson(Map<String, dynamic>.from(responseData['qr_code'] as Map));
      }

      return (
        store: store,
        items: items,
        locationWarning: locationWarning,
        categories: categories,
        total: totalItems,
        qrCode: qrCode,
      );
    } on Exception catch (e, stack) {
      Log.error('Error in getStoreByQr: $e', e, stack);
      rethrow;
    }
  }

  Future<SellerQrEligibilityModel> checkSellerQrEligibility() async {
    try {
      final response = await Api.get(url: ApiEndpoints.sellerQrEligibility);
      final data = response['data'] as Map<String, dynamic>;
      return SellerQrEligibilityModel.fromJson(data);
    } on Exception catch (e, stack) {
      Log.error('Error in checkSellerQrEligibility: $e', e, stack);
      rethrow;
    }
  }

  Future<SellerQrCodeModel?> getMySellerQr() async {
    try {
      final response = await Api.get(url: ApiEndpoints.sellerMyQr);
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        return SellerQrCodeModel.fromJson(data);
      }
      return null;
    } on Exception catch (e, stack) {
      Log.error('Error in getMySellerQr: $e', e, stack);
      rethrow;
    }
  }

  Future<SellerQrCodeModel> generateOrUpdateSellerQr({
    String? customSlug,
    String? customTagline,
    String? customColor,
    String? format,
    String? size,
    File? centerLogoFile,
  }) async {
    try {
      final Map<String, dynamic> params = {};
      if (customSlug != null && customSlug.isNotEmpty) {
        params['custom_slug'] = customSlug;
      }
      if (customTagline != null) params['custom_tagline'] = customTagline;
      if (customColor != null) params['custom_color'] = customColor;
      if (format != null) params['format'] = format;
      if (size != null) params['size'] = size;

      if (centerLogoFile != null) {
        params['center_logo'] = await MultipartFile.fromFile(
          centerLogoFile.path,
          filename: path.basename(centerLogoFile.path),
        );
      }

      final response = await Api.post(
        url: ApiEndpoints.sellerQrGenerateOrUpdate,
        parameter: params,
      );

      final data = response['data'] as Map<String, dynamic>;
      return SellerQrCodeModel.fromJson(data);
    } on Exception catch (e, stack) {
      Log.error('Error in generateOrUpdateSellerQr: $e', e, stack);
      rethrow;
    }
  }
}

