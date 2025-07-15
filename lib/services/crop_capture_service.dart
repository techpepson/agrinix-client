import 'dart:io';
import 'package:agrinix/models/crop_model.dart';
import 'package:agrinix/providers/image_capture.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CropCaptureService {
  final Ref ref;
  CropCaptureService(this.ref);

  /// Mock upload: Pretend to upload the image and return a CropModel with a fake URL and token
  Future<CropModel> uploadCropImage(File imageFile) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // In a real implementation, upload imageFile to server and get URL/token
    final fakeUrl =
        'https://example.com/uploads/${imageFile.path.split('/').last}';
    final fakeToken = 'mock-token-123';

    final cropModel = CropModel(cropImageUrl: fakeUrl, token: fakeToken);

    // Update provider state
    ref.read(imageCaptureProvider.notifier).updateImage(fakeUrl);
    ref.read(imageCaptureProvider.notifier).updateToken(fakeToken);

    return cropModel;
  }
}

/// Riverpod provider for the service
final cropCaptureServiceProvider = Provider<CropCaptureService>((ref) {
  return CropCaptureService(ref);
});
