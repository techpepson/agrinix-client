
import 'package:agrinix/core/services/app_services.dart';
import 'package:dio/dio.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";
import 'dart:developer' as dev;


class CropList {
  AppServices appServices = AppServices();
  Future<Response> fetchFarmerCrops() async {
    final baseUrl = dotenv.env['SERVER_BASE_URL'];
    if (baseUrl == null) {
      throw 'The base url is not provided';
    }

    final endpoint = '$baseUrl/crops/farmer-crops';
    final dio = Dio();

    final readToken = await appServices.readFromSecureStorage('token');

    if (readToken == null) {
      throw "Token not provided";
    }

    // get the user token from login
    final token = readToken;

    try {
      final response = await dio.get(
        endpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $token',
          },
        ),
      );
      // dev.log(response.toString());
      return response; // Return the server's response (analysis result)
    } catch (e) {
      if (e is DioException && e.response != null) {
        dev.log('Error data: ${e.response?.data}', name: 'Crop fetch  Error');
        // Try to extract a message from the server response
        final errorData = e.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          throw errorData['message'];
        } else if (errorData is String) {
          throw errorData;
        }
      }
      throw "An error occurred while fetching crops. Please try again.";
    }
  }
}
