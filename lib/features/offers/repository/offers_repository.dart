import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/features/offers/models/campaign_model.dart';
import 'package:eClassify/features/offers/models/promotion_model.dart';
import 'package:eClassify/features/offers/models/promotion_item_model.dart';
import 'package:eClassify/features/offers/models/ad_promotion_options_model.dart';
import 'package:eClassify/features/offers/models/seller_promotions_analytics_model.dart';

class OffersRepository {
  // ==================== Public Offer Zone Endpoints ====================

  List<dynamic> _extractList(dynamic raw, {String? key}) {
    if (raw == null) return const [];
    if (raw is List) return raw;
    if (raw is Map) {
      if (key != null && raw[key] is List) return raw[key] as List;
      if (raw['promotions'] is List) return raw['promotions'] as List;
      if (raw['data'] is List) return raw['data'] as List;
      if (raw['items'] is List) return raw['items'] as List;
    }
    return const [];
  }

  Future<List<CampaignModel>> getCampaigns({String status = 'active'}) async {
    final response = await Api.get(
      url: ApiEndpoints.getOffersCampaigns,
      queryParameters: {'status': status},
    );

    final data = _extractList(response['data']);
    return data.map((json) => CampaignModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<CampaignModel?> getCampaignDetail({String? slug, int? id}) async {
    final response = await Api.get(
      url: ApiEndpoints.getOffersCampaignDetail,
      queryParameters: {
        if (slug != null) 'slug': slug,
        if (id != null) 'id': id,
      },
    );

    if (response['data'] != null && response['data'] is Map<String, dynamic>) {
      return CampaignModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<PromotionModel>> getPromotions({int? campaignId, String? type}) async {
    final response = await Api.get(
      url: ApiEndpoints.getOffersPromotions,
      queryParameters: {
        if (campaignId != null) 'campaign_id': campaignId,
        if (type != null) 'promotion_type': type,
      },
    );

    final data = _extractList(response['data']);
    return data.map((json) => PromotionModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<PromotionItemModel>> getPromotionItems({
    int? promotionId,
    int? campaignId,
    String? promotionType,
    String? city,
    double? latitude,
    double? longitude,
    double? radius,
    int? page,
    int? limit,
  }) async {
    final response = await Api.get(
      url: ApiEndpoints.getOffersPromotionItems,
      queryParameters: {
        if (promotionId != null) 'promotion_id': promotionId,
        if (campaignId != null) 'campaign_id': campaignId,
        if (promotionType != null) 'promotion_type': promotionType,
        if (city != null) 'city': city,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (radius != null) 'radius': radius,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );

    final data = _extractList(response['data']);
    return data.map((json) => PromotionItemModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<PromotionItemModel>> getFlashSales({
    String? city,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    final response = await Api.get(
      url: ApiEndpoints.getOffersFlashSales,
      queryParameters: {
        if (city != null) 'city': city,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (radius != null) 'radius': radius,
      },
    );

    final data = _extractList(response['data']);
    return data.map((json) => PromotionItemModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<PromotionItemModel>> getDealsOfTheDay({
    String? city,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    final response = await Api.get(
      url: ApiEndpoints.getOffersDealsOfTheDay,
      queryParameters: {
        if (city != null) 'city': city,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (radius != null) 'radius': radius,
      },
    );

    final data = _extractList(response['data']);
    return data.map((json) => PromotionItemModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<PromotionItemModel>> getClearanceSales({
    String? city,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    final response = await Api.get(
      url: ApiEndpoints.getOffersClearanceSales,
      queryParameters: {
        if (city != null) 'city': city,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (radius != null) 'radius': radius,
      },
    );

    final data = _extractList(response['data']);
    return data.map((json) => PromotionItemModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<PromotionItemModel>> getSpotlightAds({
    String? city,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    final response = await Api.get(
      url: ApiEndpoints.getOffersSpotlightAds,
      queryParameters: {
        if (city != null) 'city': city,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (radius != null) 'radius': radius,
      },
    );

    final data = _extractList(response['data']);
    return data.map((json) => PromotionItemModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> getAvailablePromotionsData({int? itemId}) async {
    final response = await Api.get(
      url: ApiEndpoints.getSellerAvailablePromotions,
      queryParameters: {
        if (itemId != null) 'item_id': itemId,
      },
    );

    final rawData = response['data'];
    final dataList = _extractList(rawData, key: 'promotions');
    final promoModels = dataList.map((json) => PromotionModel.fromJson(json as Map<String, dynamic>)).toList();

    final isVerified = rawData is Map ? (rawData['is_verified'] == true || rawData['is_verified'] == 1) : true;
    final reqVerification = rawData is Map
        ? (rawData['requires_verification'] == true || rawData['requires_verification'] == 1 || !isVerified)
        : false;
    final reqPackage = rawData is Map ? (rawData['requires_package'] == true || rawData['requires_package'] == 1) : false;
    final eligibilityMsg = rawData is Map ? rawData['eligibility_msg']?.toString() : null;
    final remainingQuota = rawData is Map ? (rawData['remaining_quota']?.toString() ?? 'unlimited') : 'unlimited';
    final alreadySubmitted = rawData is Map && rawData['already_submitted_promotion_ids'] is List
        ? (rawData['already_submitted_promotion_ids'] as List)
            .map((e) => int.tryParse(e.toString()) ?? 0)
            .where((id) => id > 0)
            .toList()
        : <int>[];

    return {
      'promotions': promoModels,
      'is_verified': isVerified,
      'verification_status': rawData is Map ? rawData['verification_status']?.toString() : null,
      'requires_verification': reqVerification,
      'requires_package': reqPackage,
      'eligibility_msg': eligibilityMsg,
      'remaining_quota': remainingQuota,
      'already_submitted_promotion_ids': alreadySubmitted,
    };
  }

  Future<List<PromotionModel>> getAvailablePromotions({int? itemId}) async {
    final data = await getAvailablePromotionsData(itemId: itemId);
    return (data['promotions'] as List<PromotionModel>?) ?? [];
  }

  Future<AdPromotionOptionsModel> getAdPromotionOptions(int itemId) async {
    final response = await Api.get(
      url: ApiEndpoints.getSellerPromotionOptions,
      queryParameters: {'item_id': itemId},
    );

    return AdPromotionOptionsModel.fromJson(response['data'] ?? {});
  }

  Future<Map<String, dynamic>> promoteAd({
    required int itemId,
    required String promotionType,
    required int durationDays,
  }) async {
    return await Api.post(
      url: ApiEndpoints.promoteSellerAd,
      parameter: {
        'item_id': itemId,
        'promotion_type': promotionType,
        'duration_days': durationDays,
      },
    );
  }

  Future<Map<String, dynamic>> addPromotionItem({
    required int promotionId,
    required int itemId,
    required String discountType,
    required double discountValue,
    required int stockQuantity,
    bool replace = false,
  }) async {
    return await Api.post(
      url: ApiEndpoints.addSellerPromotionItem,
      parameter: {
        'promotion_id': promotionId,
        'item_id': itemId,
        'discount_type': discountType,
        'discount_value': discountValue,
        'stock_quantity': stockQuantity,
        if (replace) 'replace': 1,
      },
    );
  }

  Future<SellerPromotionsAnalyticsModel> getPromotionsAnalytics() async {
    final response = await Api.get(
      url: ApiEndpoints.getSellerPromotionsAnalytics,
    );
    return SellerPromotionsAnalyticsModel.fromJson(response['data'] ?? {});
  }

  Future<Map<String, dynamic>> getPromotionsHistory({
    String filterType = 'all',
    int? campaignId,
    String? status,
    int page = 1,
    int limit = 15,
  }) async {
    final response = await Api.get(
      url: ApiEndpoints.getSellerPromotionsHistory,
      queryParameters: {
        'filter_type': filterType,
        if (campaignId != null) 'campaign_id': campaignId,
        if (status != null) 'status': status,
        'page': page,
        'limit': limit,
      },
    );

    final data = response['data'] ?? {};
    final list = _extractList(data);
    final historyItems = list
        .map((json) => SellerPromotionHistoryItem.fromJson(json as Map<String, dynamic>))
        .toList();

    return {
      'items': historyItems,
      'current_page': data['current_page'] ?? 1,
      'last_page': data['last_page'] ?? 1,
      'total': data['total'] ?? 0,
    };
  }
}

