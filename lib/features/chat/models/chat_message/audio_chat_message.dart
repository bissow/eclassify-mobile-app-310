part of '../chat_message.dart';

final class AudioChatMessage extends ChatMessage {
  AudioChatMessage._({
    required this.audio,
    required super.senderId,
    required super.chatId,
    required super.dateTime,
    super.id,
    super.localId,
    super.sendingStatus = MessageSendingStatus.sent,
    super.uploadProgress,
  }) : super._();

  AudioChatMessage._fromJson(Json json)
    : audio = json['audio'] as String,
      super._fromJson(json);

  final String audio;

  @override
  AudioChatMessage withStatus(MessageSendingStatus status) =>
      AudioChatMessage._(
        id: id,
        senderId: senderId,
        chatId: chatId,
        dateTime: dateTime,
        localId: localId,
        sendingStatus: status,
        uploadProgress: 0,
        audio: audio,
      );

  @override
  AudioChatMessage withProgress(double progress) => AudioChatMessage._(
    id: id,
    senderId: senderId,
    chatId: chatId,
    dateTime: dateTime,
    localId: localId,
    sendingStatus: sendingStatus,
    uploadProgress: progress,
    audio: audio,
  );

  @override
  Json get toJson => {
    ...super.toJson,
    // Only called for new local messages, so `audio` is always a local path here.
    ApiParams.audio: MultipartFile.fromFileSync(
      audio,
      filename: audio.split('/').last,
    ),
  };

  @override
  String toString() {
    return 'AudioChatMessage{audio: $audio, ${super.toString()}';
  }
}
