import 'package:flutter_dotenv/flutter_dotenv.dart';
import "dart:developer" as dev;
import "package:dio/dio.dart";

class CropDiseases {
  Future<List<Map<String, dynamic>>> fetchCropDiseases() async {
    try {
      final urlEndpoint = dotenv.env["PERENUAL_API_CROP_PEST_ENDPOINT"];
      final secretKey = dotenv.env['PERENUAL_API_KEY'];
      final dio = Dio();
      //check if url endpoint and secret api key are present
      if (urlEndpoint == null) {
        dev.log("URL endpoint of value $urlEndpoint is missing");
      }
      if (secretKey == null) {
        dev.log("The API key of value $secretKey is missing");
      }

      final response = await dio.get(
        '$urlEndpoint/?key=$secretKey',
        options: Options(),
      );
      final data = (response.data['data']);
      final elements = List<Map<String, dynamic>>.from(data);

      return elements;

      //encode the response from the server
    } catch (e) {
      dev.log(e.toString());
      rethrow;
    }
  }
}
