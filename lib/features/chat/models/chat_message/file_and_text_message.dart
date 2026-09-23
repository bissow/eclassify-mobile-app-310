part of '../chat_message.dart';

final class FileAndTextMessage extends ChatMessage {
  FileAndTextMessage._({
    required this.file,
    required this.message,
    super.id,
    required super.senderId,
    required super.chatId,
    required super.dateTime,
    super.localId,
    super.sendingStatus = MessageSendingStatus.sent,
    super.uploadProgress,
  }) : super._();

  FileAndTextMessage._fromJson(Json json)
    : file = json['file'] as String,
      message = json['message'] as String,
      super._fromJson(json);

  final String file;
  final String message;

  @override
  FileAndTextMessage withStatus(MessageSendingStatus status) =>
      FileAndTextMessage._(
        id: id,
        senderId: senderId,
        chatId: chatId,
        dateTime: dateTime,
        localId: localId,
        sendingStatus: status,
        uploadProgress: 0,
        file: file,
        message: message,
      );

  @override
  FileAndTextMessage withProgress(double progress) => FileAndTextMessage._(
    id: id,
    senderId: senderId,
    chatId: chatId,
    dateTime: dateTime,
    localId: localId,
    sendingStatus: sendingStatus,
    uploadProgress: progress,
    file: file,
    message: message,
  );

  @override
  Json get toJson => {
    ...super.toJson,
    // Only called for new local messages, so `file` is always a local path here.
    ApiParams.file: MultipartFile.fromFileSync(
      file,
      filename: file.split('/').last,
    ),
    ApiParams.message: message,
  };

  @override
  String toString() {
    return 'FileAndTextMessage{file: $file, message: $message, ${super.toString()}';
  }
}
