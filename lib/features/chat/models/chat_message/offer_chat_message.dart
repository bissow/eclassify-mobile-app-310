part of '../chat_message.dart';

final class OfferChatMessage extends ChatMessage {
  OfferChatMessage._({
    required this.amount,
    this.rawAmount,
    super.id,
    required super.senderId,
    required super.chatId,
    required super.dateTime,
    super.localId,
    super.sendingStatus = MessageSendingStatus.sent,
  }) : super._();

  OfferChatMessage._fromJson(Json json)
    : amount = json['formatted_amount'].toString(),
      rawAmount = null,
      super._fromJson(json);

  /// Display string: the server's `formatted_amount`, or for a local
  /// placeholder the text as typed in the offer sheet.
  final String amount;

  /// Plain `1234.56` value sent to the API. Only set on local placeholders;
  /// server messages send [amount] back as-is, which is never needed.
  final String? rawAmount;

  @override
  OfferChatMessage withStatus(MessageSendingStatus status) =>
      OfferChatMessage._(
        id: id,
        senderId: senderId,
        chatId: chatId,
        dateTime: dateTime,
        localId: localId,
        sendingStatus: status,
        amount: amount,
        rawAmount: rawAmount,
      );

  @override
  OfferChatMessage withProgress(double progress) => this;

  @override
  Json get toJson => {...super.toJson, ApiParams.amount: rawAmount ?? amount};

  @override
  String toString() {
    return 'OfferChatMessage{amount: $amount, ${super.toString()}';
  }
}
