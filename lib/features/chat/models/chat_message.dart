library chat_message;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/network/api_params.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:uuid/uuid.dart';

part '../factories/chat_message_factory.dart';
part 'chat_message/text_chat_message.dart';
part 'chat_message/file_chat_message.dart';
part 'chat_message/audio_chat_message.dart';
part 'chat_message/file_and_text_message.dart';
part 'chat_message/offer_chat_message.dart';

enum ChatMessageType {
  audio('audio'),
  file('file'),
  fileAndText('file_and_text'),
  text('text'),
  offer('offer');

  const ChatMessageType(this.value);

  final String value;

  static ChatMessageType parse(String value) {
    return ChatMessageType.values.firstWhere((type) => type.value == value);
  }
}

enum MessageSendingStatus { sending, sent, failed }

abstract base class ChatMessage {
  ChatMessage._({
    this.id,
    required this.senderId,
    required this.chatId,
    required this.dateTime,
    this.localId,
    this.sendingStatus = MessageSendingStatus.sent,
    this.uploadProgress,
  }) : preview = null;

  factory ChatMessage.parse(Json json) {
    return ChatMessageFactory.fromServerJson(json);
  }

  ChatMessage._fromJson(Json json)
    : id = json['id'] as int?,
      senderId = json['sender_id'] as int,
      chatId = int.parse(json['item_offer_id'].toString()),
      dateTime = DateTime.parse(json['created_at'] as String).toLocal(),
      localId = json['client_id'] as String?,
      preview = json['last_chat_message'] as String?,
      sendingStatus = MessageSendingStatus.sent,
      uploadProgress = null;

  final int? id;
  final int senderId;
  final int chatId;
  final DateTime dateTime;

  /// Unique identifier for local tracking before the message is assigned a server ID.
  /// This is sent as 'client_id' to the server and echoed back.
  final String? localId;

  /// Current status of the message sending process.
  final MessageSendingStatus sendingStatus;

  /// Progress of media upload (0.0 to 1.0). Null for text messages or sent messages.
  final double? uploadProgress;

  /// Server-built one-line inbox preview ("Sent a photo", offer text, ...).
  /// Only present on messages parsed from the API; local placeholders and
  /// [withStatus]/[withProgress] copies carry null.
  final String? preview;

  bool get isLocal => localId != null && id == null;

  bool get isSent => sendingStatus == MessageSendingStatus.sent;

  bool get isFailed => sendingStatus == MessageSendingStatus.failed;

  bool get isSending => sendingStatus == MessageSendingStatus.sending;

  /// Returns a copy with the given sending status (and reset upload progress on failure/retry).
  ChatMessage withStatus(MessageSendingStatus status);

  /// Returns a copy with updated upload progress. No-op for messages without media.
  ChatMessage withProgress(double progress);

  @override
  String toString() {
    return 'ChatMessageV2{id: $id, localId: $localId, status: $sendingStatus, sender: $senderId, chatId: $chatId, dateTime: $dateTime}';
  }

  /// Maps internal fields to API parameter keys.
  /// Subclasses should override and call super.toJson() to append their specific data.
  Json get toJson => {
    ApiParams.itemOfferId: chatId,
    if (localId != null) ApiParams.clientId: localId,
  };
}
