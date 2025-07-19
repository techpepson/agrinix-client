class MessageModel {
  MessageModel({
    required this.messageTitle,
    required this.messageBody,
    this.messageImage,
    this.messageLink,
  });
  final String messageTitle;
  final String messageBody;
  final String? messageImage;
  final String? messageLink;

  MessageModel copyWith({
    String? messageTitle,
    String? messageBody,
    String? messageImage,
    String? messageLink,
  }) {
    return MessageModel(
      messageTitle: messageTitle ?? this.messageTitle,
      messageBody: messageBody ?? this.messageBody,
      messageImage: messageImage ?? this.messageImage,
      messageLink: messageLink ?? this.messageLink,
    );
  }
}
