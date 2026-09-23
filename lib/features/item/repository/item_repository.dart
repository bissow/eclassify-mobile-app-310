import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/models/file_resource.dart';
import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/background_upload_utility.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/chat/models/chat.dart';
import 'package:eClassify/features/item/enums/item_status.dart';
import 'package:eClassify/features/item/models/ad_posting_data.dart';
import 'package:eClassify/features/item/models/item.dart';
import 'package:eClassify/features/item/models/item_metadata.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/item/models/my_item.dart';
import 'package:eClassify/features/item/models/product_video.dart';
import 'package:eClassify/features/location/models/leaf_location.dart';
import 'package:eClassify/features/review/models/purchased_item.dart';
import 'package:path/path.dart' as path;

class ItemRepository {
  ItemRepository._internal();

  static final ItemRepository _instance = ItemRepository._internal();

  static ItemRepository get instance => _instance;

  Future<({MyItem item, bool isUploadInProgress})> createAdvertisement({
    required AdPostingData data,
  }) async {
    try {
      final content = data.toJson;
      final isEdit = data.id != null;

      if (data.images.isNotNullAndNotEmpty) {
        final images = await _processImages(data.images!);
        content['gallery_images'] = images;
        content.remove('images');
      }

      if (data.customFields.isNotNullAndNotEmpty) {
        final customFieldsData = _processCustomFields(data.customFields!);
        if (customFieldsData.fields.isNotNullAndNotEmpty) {
          content['custom_field_translations'] = customFieldsData.fields;
        }
        if (customFieldsData.files.isNotNullAndNotEmpty) {
          content['custom_field_files'] = customFieldsData.files;
        }
      }

      if (data.localizedContent.isNotNullAndNotEmpty) {
        content['translations'] = jsonEncode(
          data.localizedContent?.map(
            (l, data) => MapEntry(l.toString(), data.toJson),
          ),
        );
      }

      if (data.productVideo != null &&
          data.productVideo!.type != ProductVideoType.custom) {
        content['video_link'] = data.productVideo!.videoSource.filePath;
        content['video_type'] = data.productVideo!.type.key;
      }

      final response = await Api.post(
        url: isEdit ? ApiEndpoints.updateItem : ApiEndpoints.addItem,
        parameter: content,
      );

      final item = JsonHelper.parseObject(
        response['data'] as Json,
        MyItem.fromJson,
      );

      Map<String, String> files = {};
      if (data.productVideo != null &&
          data.productVideo!.type == ProductVideoType.custom &&
          data.productVideo!.videoSource is LocalFileResource) {
        files['product_video'] =
            (data.productVideo!.videoSource as LocalFileResource).filePath;
      }

      if (data.videoAd != null && data.videoAd is LocalFileResource) {
        files['video'] = (data.videoAd as LocalFileResource).filePath;
      }

      if (data.thumbnail != null && data.thumbnail is LocalFileResource) {
        files['thumbnail'] = (data.thumbnail as LocalFileResource).filePath;
      }

      if (files.isNotNullAndNotEmpty) {
        BackgroundUploadUtility.uploadMedia(
          itemId: item.id.toString(),
          files: files,
        );
      }

      return (item: item, isUploadInProgress: files.isNotNullAndNotEmpty);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<List<dynamic>> _processImages(List<FileResource> images) async {
    final files = List.empty(growable: true);
    final multiPartFiles = List<Future<MultipartFile>>.empty(growable: true);
    for (final image in images) {
      if (image is RemoteFileResource) {
        files.add(image.filePath);
        continue;
      } else {
        final file = (image as LocalFileResource).file;
        multiPartFiles.add(
          MultipartFile.fromFile(file.path, filename: path.basename(file.path)),
        );
      }
    }
    final result = await Future.wait(multiPartFiles);
    files.addAll(result);
    return files;
  }

  ({String? fields, Map<String, MultipartFile>? files}) _processCustomFields(
    Map<int, CustomFieldData> customFields,
  ) {
    final Map<String, Map<String, dynamic>> processedCustomFields = {};
    final Map<String, MultipartFile> processedFiles = {};

    for (final field in customFields.entries) {
      final fieldId = field.key;
      final fieldData = field.value;
      final Map<String, dynamic> newFieldData = {};

      for (final entry in fieldData.entries) {
        final key = entry.key;
        final value = entry.value;
        if (value is String) {
          newFieldData[key.toString()] = [value];
        } else if (value is FileResource) {
          if (value is RemoteFileResource) {
            newFieldData[key.toString()] = [value.filePath];
          } else {
            final filePath = value.filePath;
            processedFiles[key.toString()] = MultipartFile.fromFileSync(
              filePath,
              filename: path.basename(filePath),
            );
          }
        } else {
          newFieldData[key.toString()] = value;
        }
      }
      processedCustomFields[fieldId.toString()] = newFieldData;
    }

    return (fields: jsonEncode(processedCustomFields), files: processedFiles);
  }

  Future<PaginatedResult<MyItemPreview>> getMyItems({
    required String? status,
    int page = 1,
  }) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getMyItem,
        queryParameters: {ApiParams.status: ?status, ApiParams.page: page},
      );

      final items = JsonHelper.parseList(
        response['data']['data'] as List?,
        MyItemPreview.fromJson,
      );
      final total = response['data']['total'] as int;

      return PaginatedResult<MyItemPreview>(data: items, total: total);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<Item?> fetchItemFromItemId(int id, {bool isMyAd = false}) =>
      _fetchItemInternal(id: id, isMyAd: isMyAd);

  Future<Item?> fetchItemFromItemSlug(String slug, {bool isMyAd = false}) =>
      _fetchItemInternal(slug: slug, isMyAd: isMyAd);

  /// Internal helper to fetch item details.
  ///
  /// NOTE: The ownership auto-detection and fallback logic below was introduced
  /// primarily for deep links and push notifications where [isMyAd] is unknown upfront.
  ///
  /// A cleaner long-term backend solution would be to have a single dedicated
  /// item details API endpoint that dynamically inspects the current user's Auth token
  /// and returns the appropriate payload (`MyItem` vs `Item`) accordingly.
  Future<Item?> _fetchItemInternal({
    int? id,
    String? slug,
    bool isMyAd = false,
  }) async {
    assert(
      id != null || slug != null,
      'Either id or slug should be provided to fetch item data',
    );
    final queryParameters = <String, dynamic>{
      ApiParams.id: ?id,
      ApiParams.slug: ?slug,
    };

    try {
      // 1. If caller explicitly passed isMyAd = true, use getMyItemApi directly
      if (isMyAd) {
        final response = await Api.get(
          url: ApiEndpoints.getMyItem,
          queryParameters: queryParameters,
        );

        return JsonHelper.parseObjectOrNull(
          response['data'] as Json?,
          MyItem.fromJson,
        );
      }

      // 2. Otherwise, try public getItemApi first
      final response = await Api.get(
        url: ApiEndpoints.getItem,
        queryParameters: queryParameters,
      );

      final data = response['data'] as Json?;

      // CASE 1: Public API returned item data (Ad is Approved)
      if (data != null && data.isNotEmpty) {
        final currentUserId = AppSession.currentUser?.id;
        final sellerId = data['user_id']?.toString();

        // Auto-detect ownership: If current user owns this item, fetch full MyItem from getMyItemApi
        if (currentUserId != null && currentUserId == sellerId) {
          final myResponse = await Api.get(
            url: ApiEndpoints.getMyItem,
            queryParameters: queryParameters,
          );
          final myData = myResponse['data'] as Json?;
          if (myData != null && myData.isNotEmpty) {
            return MyItem.fromJson(myData);
          }
        }
        return Item.fromJson(data);
      }

      // CASE 2: Public API returned null/empty (Ad is Pending/Unapproved)
      // Fallback: If user is authenticated, try getMyItemApi to see if it's their unapproved ad
      if (AppSession.isAuthenticated) {
        final myResponse = await Api.get(
          url: ApiEndpoints.getMyItem,
          queryParameters: queryParameters,
        );
        final myData = myResponse['data'] as Json?;
        if (myData != null && myData.isNotEmpty) {
          return MyItem.fromJson(myData);
        }
      }

      return null;
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  Future<String> changeItemStatus({
    required int itemId,
    required ItemStatus status,
    int? soldTo,
  }) async {
    final response = await Api.post(
      url: ApiEndpoints.updateItemStatus,
      parameter: {
        ApiParams.status: status.value,
        ApiParams.itemId: itemId,
        ApiParams.soldTo: ?soldTo,
      },
    );
    return response['message'] as String;
  }

  Future<String> createFeaturedAds({required int itemId}) async {
    try {
      final response = await Api.post(
        url: ApiEndpoints.makeItemFeatured,
        parameter: {ApiParams.itemId: itemId},
      );
      return response['message'] as String;
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  Future<List<ItemPreview>> fetchItemFromCatId({
    required int categoryId,
    LeafLocation? location,
    int? excludedItemId,
  }) async {
    final parameters = {
      ApiParams.categoryId: categoryId,
      ApiParams.excludedItemId: ?excludedItemId,
      ...?location?.toApiJson,
    };

    final response = await Api.get(
      url: ApiEndpoints.getItem,
      queryParameters: parameters,
    );

    final items = JsonHelper.parseList(
      response['data']['data'] as List?,
      ItemPreview.fromJson,
    );

    return items;
  }

  Future<void> deleteItem({int? id, Iterable<int>? ids}) async {
    assert(
      (id != null) ^ (ids != null),
      "Either id or ids should be present but not both",
    );
    Map<String, dynamic> parameters = {};
    if (id != null) {
      parameters[ApiParams.itemId] = id;
    } else {
      parameters[ApiParams.itemIds] = ids!.join(",");
    }
    await Api.post(url: ApiEndpoints.deleteItem, parameter: parameters);
  }

  Future<Chat> createOffer(int id, double? amount) async {
    try {
      final response = await Api.post(
        url: ApiEndpoints.itemOffer,
        parameter: {ApiParams.itemId: id, ApiParams.amount: ?amount},
      );

      final responseMap = response['data'] as Json;
      final itemMap = responseMap.remove('item');
      itemMap['formatted_price'] = responseMap['item_formatted_price'];

      final chat = Chat.fromJson({
        ...response['data'] as Json,
        'item': itemMap,
        'last_message_time': response['data']['updated_at'] as String,
        'item_id': int.parse(response['data']['item_id'].toString()),
        'formatted_amount':
            response['data']['item_offer_formatted_amount'] as String?,
      });

      return chat;
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  Future<PaginatedResult<ItemPreview>> getItem({
    required ItemMetaData metadata,
    int page = 1,
  }) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getItem,
        queryParameters: {...metadata.toJson, ApiParams.page: page},
      );

      final items = JsonHelper.parseList(
        response['data']['data'] as List?,
        ItemPreview.fromJson,
      );

      final total = response['data']['total'] as int;

      return PaginatedResult(data: items, total: total);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<PaginatedResult<ItemPreview>> getSellerItems({
    required int sellerId,
    int page = 1,
  }) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getItem,
        queryParameters: {ApiParams.userId: sellerId, ApiParams.page: page},
      );

      final items = JsonHelper.parseList(
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

  Future<ItemStatus> getItemStatus({required int itemId}) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getItemStatus,
        queryParameters: {'item_id': itemId},
      );

      final status = ItemStatus.parse(response['data']['status'] as String);

      return status;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      return ItemStatus.unknown;
    }
  }

  Future<PaginatedResult<PurchasedItem>> getMyPurchasedItem({
    int page = 1,
  }) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.myPurchasedItems,
        queryParameters: {ApiParams.page: page},
      );

      final items = JsonHelper.parseList(
        response['data']['data'] as List?,
        PurchasedItem.fromJson,
      );
      final total = response['data']['total'] as int;

      return PaginatedResult<PurchasedItem>(data: items, total: total);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
