import 'package:agrinix/models/crop_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageCaptureProvider extends StateNotifier<CropModel> {
  ImageCaptureProvider() : super(CropModel(cropImageUrl: "", token: ""));

  void updateImage(String value) {
    state = state.copyWith(cropImageUrl: value);
  }

  void updateToken(String value) {
    state = state.copyWith(token: value);
  }
}

final imageCaptureProvider =
    StateNotifierProvider<ImageCaptureProvider, CropModel>((_) {
      return ImageCaptureProvider();
    });
