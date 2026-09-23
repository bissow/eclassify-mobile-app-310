part of '../chat_message.dart';

final class FileChatMessage extends ChatMessage {
  FileChatMessage._({
    required this.file,
    super.id,
    required super.senderId,
    required super.chatId,
    required super.dateTime,
    super.localId,
    super.sendingStatus = MessageSendingStatus.sent,
    super.uploadProgress,
  }) : super._();

  FileChatMessage._fromJson(Json json)
    : file = json['file'] as String,
      super._fromJson(json);

  final String file;

  @override
  FileChatMessage withStatus(MessageSendingStatus status) => FileChatMessage._(
    id: id,
    senderId: senderId,
    chatId: chatId,
    dateTime: dateTime,
    localId: localId,
    sendingStatus: status,
    uploadProgress: 0,
    file: file,
  );

  @override
  FileChatMessage withProgress(double progress) => FileChatMessage._(
    id: id,
    senderId: senderId,
    chatId: chatId,
    dateTime: dateTime,
    localId: localId,
    sendingStatus: sendingStatus,
    uploadProgress: progress,
    file: file,
  );

  @override
  Json get toJson => {
    ...super.toJson,
    // Only called for new local messages, so `file` is always a local path here.
    ApiParams.file: MultipartFile.fromFileSync(
      file,
      filename: file.split('/').last,
    ),
  };

  @override
  String toString() {
    return 'FileChatMessage{file: $file, ${super.toString()}';
  }
}
