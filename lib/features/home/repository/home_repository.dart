// ignore_for_file: unused_import

import 'package:eClassify/core/models/data_output.dart';
import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/category/models/category.dart';
import 'package:eClassify/features/home/models/featured_section.dart';
import 'package:eClassify/features/home/models/home_section.dart';
import 'package:eClassify/features/home/models/home_slider.dart';
import 'package:eClassify/features/item/models/item.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/location/models/leaf_location.dart';

class HomeRepository {
  HomeRepository._internal();

  static final HomeRepository _instance = HomeRepository._internal();

  static HomeRepository get instance => _instance;

  Future<List<HomeSection>> getHomeConfiguration() async {
    try {
      final response = await Api.get(url: ApiEndpoints.getHomeConfiguration);

      final sections = JsonHelper.parseList(
        response['data']['sections'] as List?,
        (json) {
          try {
            return HomeSection.fromJson(json);
          } catch (e, stack) {
            Log.error('Error parsing HomeSection: ${e.toString()}', e, stack);
            return null;
          }
        },
      ).nonNulls.toList();

      return sections;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<List<HomeSlider>> getSliders({required LeafLocation? location}) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getSlider,
        queryParameters: {
          ApiParams.city: ?location?.city?.canonical,
          ApiParams.state: ?location?.state?.canonical,
          ApiParams.country: ?location?.country?.canonical,
        },
      );

      final sliders = JsonHelper.parseList(
        response['data'] as List?,
        HomeSlider.parse,
      );
      return sliders;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<List<Category>> getPopularCategories() async {
    try {
      final response = await Api.get(url: ApiEndpoints.getPopularCategories);
      final categories = JsonHelper.parseList(
        response['data'] as List?,
        Category.fromJson,
      );
      return categories;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<List<FeaturedSection>> getFeaturedSection({
    required LeafLocation? location,
  }) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getFeaturedSection,
        queryParameters: location?.toApiJson,
      );
      final sections = JsonHelper.parseList(
        response['data'] as List?,
        FeaturedSection.fromJson,
      );
      return sections.where((element) => element.items.isNotEmpty).toList();
    } catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<PaginatedResult<ItemPreview>> fetchHomeAllItems({
    required int page,
    required LeafLocation? location,
  }) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getItem,
        queryParameters: {
          ApiParams.page: page,
          ...?location?.toApiJson,
          // To Receive global items if none are available at given location
          'current_page': 'home',
        },
      );
      final items = JsonHelper.parseList(
        response['data']['data'] as List?,
        ItemPreview.fromJson,
      );
      final total = response['data']['total'] as int;

      return PaginatedResult(
        data: items,
        total: total,
        metadata: StringMetadata(response['message'] as String),
      );
    } catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
