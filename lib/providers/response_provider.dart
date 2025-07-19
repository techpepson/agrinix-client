import 'package:agrinix/models/response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponseProvider extends StateNotifier<ResponseModel> {
  ResponseProvider() : super(ResponseModel(responseBody: '', messageId: ''));

  void updateResponseBody(String body) {
    state = state.copyWith(responseBody: body);
  }

  void updateMessageId(String id) {
    state = state.copyWith(messageId: id);
  }

  void clearResponse() {
    state = ResponseModel(responseBody: '', messageId: '');
  }
}

final responseProvider = StateNotifierProvider<ResponseProvider, ResponseModel>(
  (ref) => ResponseProvider(),
);
