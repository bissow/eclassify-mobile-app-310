import 'package:eClassify/features/chat/models/chat.dart';
import 'package:eClassify/features/chat/models/item_offer.dart';
import 'package:eClassify/core/models/user_preview.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/utils/log.dart';

class ChatHistoryRepository {
  ChatHistoryRepository._internal();

  static final ChatHistoryRepository _instance =
      ChatHistoryRepository._internal();

  static ChatHistoryRepository get instance => _instance;

  Future<Json> getSellerItemOffers({int page = 1, String? search}) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.chatItemOffers,
        queryParameters: {'type': 'seller', 'page': page, 'search': ?search},
      );

      final itemOffers = JsonHelper.parseList(
        response['data']['data'] as List?,
        ItemOffer.fromJson,
      );

      final hasMore = response['data']['per_page'] == itemOffers.length;

      return {'offers': itemOffers, 'has_more': hasMore};
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<Json> getSellerItemChats({
    required int itemId,
    int page = 1,
    String? search,
  }) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getChatList,
        queryParameters: {
          ApiParams.type: 'seller',
          'item_id': itemId,
          'page': page,
          'search': ?search,
        },
      );

      final chats = JsonHelper.parseList(
        response['data']['data'] as List?,
        Chat.fromJson,
      );

      final hasMore = response['data']['per_page'] == chats.length;

      return {'chats': chats, 'has_more': hasMore};
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<Json> getBuyerItemChats({int page = 1, String? search}) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getChatList,
        queryParameters: {ApiParams.type: 'buyer', 'page': page, 'search': ?search},
      );

      final chats = JsonHelper.parseList(
        response['data']['data'] as List?,
        Chat.fromJson,
      );

      final hasMore = response['data']['per_page'] == chats.length;

      return {'chats': chats, 'has_more': hasMore};
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<Chat> getChatByItemOfferId({required int itemOfferId}) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getChatList,
        queryParameters: {ApiParams.type: 'buyer', 'item_offer_id': itemOfferId},
      );

      final chats = JsonHelper.parseList(
        response['data']['data'] as List?,
        Chat.fromJson,
      );

      if (chats.isEmpty) {
        throw ApiException("Chat not found");
      }
      return chats.first;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<void> deleteChat({required List<int> itemOfferIds}) async {
    try {
      await Api.post(
        url: ApiEndpoints.deleteChat,
        parameter: {ApiParams.itemOfferId: itemOfferIds},
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<void> deleteChatMessages({
    required int itemOfferId,
    required List<int> messageIds,
  }) async {
    try {
      await Api.post(
        url: ApiEndpoints.deleteChatMessages,
        parameter: {ApiParams.itemOfferId: itemOfferId, ApiParams.messageIds: messageIds},
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<List<UserPreview>> getBlockedUsers() async {
    try {
      final response = await Api.get(url: ApiEndpoints.blockedUsersList);

      final blockedUsers = JsonHelper.parseList(
        response['data'] as List?,
        UserPreview.fromJson,
      );

      return blockedUsers;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
