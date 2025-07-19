import 'dart:io';
import 'package:agrinix/core/services/app_services.dart';
import 'package:agrinix/providers/image_capture.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
// Added for base64Encode
import 'dart:developer' as dev;

class CropCaptureService {
  CropCaptureService();

  AppServices appServices = AppServices();

  /// Uploads the image as base64 to the server and returns the analysis result.
  Future<Response> uploadCropImage(File? imageFile, WidgetRef ref) async {
    final baseUrl = dotenv.env['SERVER_BASE_URL'];
    if (baseUrl == null) {
      throw 'The base url is not provided';
    }

    final endpoint = '$baseUrl/crops/detect-disease';
    final dio = Dio();

    // Prepare the request body as a real file upload (not base64)
    final fileName = imageFile!.path.split('/').last;
    final body = FormData.fromMap({
      "cropImage": await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });

    final readToken = await appServices.readFromSecureStorage('token');

    if (readToken == null) {
      throw "Token not provided";
    }

    // If you need to send a token, get it from your provider/model
    final model = ref.watch(imageCaptureProvider);
    final token = readToken;

    try {
      final response = await dio.post(
        endpoint,
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'multipart/formdata',
            'authorization': 'Bearer $token',
          },
        ),
      );
      dev.log(response.toString());
      return response; // Return the server's response (analysis result)
    } catch (e) {
      if (e is DioException && e.response != null) {
        dev.log(
          'Error data: ${e.response?.data}',
          name: 'Crop image upload Error',
        );
        // Try to extract a message from the server response
        final errorData = e.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          throw errorData['message'];
        } else if (errorData is String) {
          throw errorData;
        }
      }
      throw "An error occurred while sending image. Please try again.";
    }
  }

  //get the processing results
  // Future<Response> processResults() async {
  //   final baseUrl = dotenv.env['SERVER_BASE_URL'];
  //   if (baseUrl == null) {
  //     throw 'The base url is not provided';
  //   }

  //   final endpoint = '$baseUrl/api/crops/detect-disease';
  //   final dio = Dio();

  //   final readToken = await appServices.readFromSecureStorage('token');

  //   if (readToken == null) {
  //     throw "Token not provided";
  //   }

  //   final token = readToken;

  //   try {
  //     final response = await dio.get(
  //       endpoint,
  //       options: Options(
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'authorization': 'Bearer $token',
  //         },
  //       ),
  //     );
  //     return response.data; // Return the server's response (analysis result)
  //   } catch (e) {
  //     if (e is DioException && e.response != null) {
  //       dev.log(
  //         'Error data: ${e.response?.data}',
  //         name: 'Crop disease detection Error',
  //       );
  //       // Try to extract a message from the server response
  //       final errorData = e.response?.data;
  //       if (errorData is Map && errorData['message'] != null) {
  //         throw errorData['message'];
  //       } else if (errorData is String) {
  //         throw errorData;
  //       }
  //     }
  //     throw "An error occurred while getting disease info. Please try again.";
  //   }
  // }
}
