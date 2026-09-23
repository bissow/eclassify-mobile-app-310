import 'package:eClassify/core/utils/json_helper.dart';

class StoreModel {
  final int id;
  final int userId;
  final String name;
  final String slug;
  final String? description;
  final String? logo;
  final String? banner;
  final String? email;
  final String? contact;
  final String? countryCode;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? state;
  final String? country;
  final int? areaId;
  final String? areaName;
  final String? website;
  final String? taxNumber;
  final String? openingTime;
  final String? closingTime;
  final List<String>? workingDays;
  final bool isVerified;
  final String status;
  final StoreDistanceModel? distance;
  final StoreStatsModel? stats;
  final StoreOwnerModel? owner;

  StoreModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.slug,
    this.description,
    this.logo,
    this.banner,
    this.email,
    this.contact,
    this.countryCode,
    this.address,
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    this.country,
    this.areaId,
    this.areaName,
    this.website,
    this.taxNumber,
    this.openingTime,
    this.closingTime,
    this.workingDays,
    this.isVerified = false,
    this.status = 'active',
    this.distance,
    this.stats,
    this.owner,
  });

  factory StoreModel.fromJson(Json json) {
    List<String>? days;
    if (json['working_days'] != null) {
      if (json['working_days'] is List) {
        days = (json['working_days'] as List).map((e) => e.toString()).toList();
      }
    }

    return StoreModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      logo: json['logo'] as String?,
      banner: json['banner'] as String?,
      email: json['email'] as String?,
      contact: json['contact'] as String?,
      countryCode: json['country_code'] as String?,
      address: json['address'] as String?,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      areaId: json['area_id'] as int?,
      areaName: json['area'] != null && json['area'] is Map
          ? (json['area'] as Map)['name']?.toString()
          : null,
      website: json['website'] as String?,
      taxNumber: json['tax_number'] as String?,
      openingTime: json['opening_time'] as String?,
      closingTime: json['closing_time'] as String?,
      workingDays: days,
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      status: json['status'] as String? ?? 'active',
      distance: json['distance'] != null && json['distance'] is Map
          ? StoreDistanceModel.fromJson(json['distance'] as Json)
          : null,
      stats: json['stats'] != null && json['stats'] is Map
          ? StoreStatsModel.fromJson(json['stats'] as Json)
          : null,
      owner: json['owner'] != null && json['owner'] is Map
          ? StoreOwnerModel.fromJson(json['owner'] as Json)
          : null,
    );
  }
}

class StoreDistanceModel {
  final int meters;
  final double kilometers;
  final String formatted;

  StoreDistanceModel({
    required this.meters,
    required this.kilometers,
    required this.formatted,
  });

  factory StoreDistanceModel.fromJson(Json json) {
    return StoreDistanceModel(
      meters: json['meters'] as int? ?? 0,
      kilometers: json['kilometers'] != null
          ? double.tryParse(json['kilometers'].toString()) ?? 0.0
          : 0.0,
      formatted: json['formatted'] as String? ?? '',
    );
  }
}

class StoreStatsModel {
  final int activeItemsCount;
  final int totalItemsCount;
  final double averageRating;
  final int totalReviews;
  final int followersCount;

  StoreStatsModel({
    required this.activeItemsCount,
    required this.totalItemsCount,
    required this.averageRating,
    required this.totalReviews,
    required this.followersCount,
  });

  factory StoreStatsModel.fromJson(Json json) {
    return StoreStatsModel(
      activeItemsCount: json['active_items_count'] as int? ?? 0,
      totalItemsCount: json['total_items_count'] as int? ?? 0,
      averageRating: json['average_rating'] != null
          ? double.tryParse(json['average_rating'].toString()) ?? 0.0
          : 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      followersCount: json['followers_count'] as int? ?? 0,
    );
  }
}

class StoreOwnerModel {
  final int id;
  final String name;
  final String? profile;
  final String? countryCode;
  final bool isVerified;

  StoreOwnerModel({
    required this.id,
    required this.name,
    this.profile,
    this.countryCode,
    this.isVerified = false,
  });

  factory StoreOwnerModel.fromJson(Json json) {
    return StoreOwnerModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      profile: json['profile'] as String?,
      countryCode: json['country_code'] as String?,
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
    );
  }
}
