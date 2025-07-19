class ResponseModel {
  ResponseModel({required this.responseBody, required this.messageId});
  final String responseBody;
  final String messageId;

  ResponseModel copyWith({String? responseBody, String? messageId}) {
    return ResponseModel(
      responseBody: responseBody ?? this.responseBody,
      messageId: messageId ?? this.messageId,
    );
  }
}
