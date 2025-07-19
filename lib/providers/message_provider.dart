import 'package:agrinix/models/message_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageProvider extends StateNotifier<MessageModel> {
  MessageProvider() : super(MessageModel(messageTitle: '', messageBody: ''));

  void updateMessageTitle(String title) {
    state = state.copyWith(messageTitle: title);
  }

  void updateMessageBody(String body) {
    state = state.copyWith(messageBody: body);
  }

  void updateMessageImage(String image) {
    state = state.copyWith(messageImage: image);
  }

  void updateMessageLink(String link) {
    state = state.copyWith(messageLink: link);
  }

  void clearMessage() {
    state = MessageModel(messageTitle: '', messageBody: '');
  }
}

final messageProvider = StateNotifierProvider<MessageProvider, MessageModel>(
  (ref) => MessageProvider(),
);
