part of '../chat_message.dart';

final class TextChatMessage extends ChatMessage {
  TextChatMessage._({
    required this.message,
    super.id,
    required super.senderId,
    required super.chatId,
    required super.dateTime,
    super.localId,
    super.sendingStatus = MessageSendingStatus.sent,
  }) : super._();

  TextChatMessage._fromJson(Json json)
    : message = json['message'] as String,
      super._fromJson(json);

  final String message;

  @override
  TextChatMessage withStatus(MessageSendingStatus status) => TextChatMessage._(
    id: id,
    senderId: senderId,
    chatId: chatId,
    dateTime: dateTime,
    localId: localId,
    sendingStatus: status,
    message: message,
  );

  @override
  TextChatMessage withProgress(double progress) => this;

  @override
  Json get toJson => {...super.toJson, ApiParams.message: message};

  @override
  String toString() {
    return 'TextChatMessage{message: $message, ${super.toString()}';
  }
}
