import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/chat/models/chat_message.dart';

class ChatRepository {
  ChatRepository._internal();

  static final ChatRepository _instance = ChatRepository._internal();

  static ChatRepository get instance => _instance;

  /// Fetches messages for a specific chat (item offer).
  Future<PaginatedResult<ChatMessage>> getMessages({
    required int chatId,
    int page = 1,
  }) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.chatMessages,
        queryParameters: {ApiParams.itemOfferId: chatId, ApiParams.page: page},
      );

      final messages = JsonHelper.parseList(
        response['data']['data'] as List?,
        ChatMessage.parse,
      );
      final total = response['data']['total'] as int;

      return PaginatedResult(total: total, data: messages);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  /// Sends a message to a chat.
  /// This method uses the message's [toJson] implementation to generate API parameters,
  /// allowing for a clean, model-driven interface.
  /// [onProgress] captures multipart upload progress for media messages.
  Future<ChatMessage> sendMessage(
    ChatMessage message, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final response = await Api.post(
        url: ApiEndpoints.sendMessage,
        parameter: message.toJson,
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
        catchApiError: false,
      );

      if (response['error'] == true) {
        if (response['data']?['key'] == 'blocked_by_other_user') {
          throw ApiException('blocked_by_other_user');
        } else {
          throw ApiException(response['message'].toString());
        }
      }
      return ChatMessage.parse(response['data'] as Map<String, dynamic>);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  /// Toggles blocking/unblocking a user.
  Future<void> toggleBlockUser({
    required int userId,
    bool isUserBlocked = false,
  }) async {
    try {
      final parameters = {ApiParams.blockedUserId: userId};
      final endpoint = isUserBlocked
          ? ApiEndpoints.unBlockUser
          : ApiEndpoints.blockUser;
      await Api.post(url: endpoint, parameter: parameters);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  /// Deletes multiple messages by their IDs.
  Future<void> deleteMessages(int chatId, List<int> ids) async {
    try {
      final parameters = {
        ApiParams.itemOfferId: chatId,
        ApiParams.messageIds: ids,
      };
      await Api.post(
        url: ApiEndpoints.deleteChatMessages,
        parameter: parameters,
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<List<String>> getChatTemplates({required int itemId}) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.chatTemplates,
        queryParameters: {ApiParams.itemId: itemId},
      );

      final templates = JsonHelper.serializeList(
        response['data'] as List?,
        (value) => value.toString(),
      );

      return templates;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<List<String>> getSafetyTips() async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getTips,
        queryParameters: {},
      );

      final tips = JsonHelper.parseList(
        response['data'] as List?,
        (json) => json['translated_name'] as String,
      );

      return tips;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
