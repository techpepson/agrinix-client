import 'dart:io';

import 'package:agrinix/core/services/app_services.dart';
import 'package:agrinix/models/response_model.dart';
import 'package:agrinix/providers/message_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrinix/providers/response_provider.dart';
import 'dart:developer' as dev;

class MessagesService {
  final Dio dio = Dio();
  final AppServices appServices = AppServices();

  Future<Response> sendMessage(WidgetRef ref, File? imageFile) async {
    try {
      final baseUrl = dotenv.env['SERVER_BASE_URL'];
      final token = await appServices.readFromSecureStorage('token');
      if (token == null) {
        throw 'Token not found';
      }

      if (baseUrl == null) {
        throw 'The base url is not provided';
      }
      final endpoint = '$baseUrl/community/create-message';

      final model = ref.watch(messageProvider);

      final body = FormData.fromMap({
        'messageTitle': model.messageTitle,
        'messageBody': model.messageBody,
        'messageImage':
            imageFile == null
                ? null
                : await MultipartFile.fromFile(
                  imageFile.path,
                  filename: imageFile.path.split('/').last,
                ),
        'messageLink': model.messageLink,
      });

      final response = await dio.post(
        endpoint,
        data: body,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          throw errorData['message'];
        } else if (errorData is String) {
          throw errorData;
        }
      }
      throw "An error occurred while sending message. Please try again.";
    }
  }

  Future<Response> sendResponse(WidgetRef ref, String messageId) async {
    try {
      final baseUrl = dotenv.env['SERVER_BASE_URL'];
      final token = await appServices.readFromSecureStorage('token');
      if (token == null) {
        throw 'Token not found';
      }

      if (baseUrl == null) {
        throw 'The base url is not provided';
      }
      final endpoint = '$baseUrl/community/create-response';

      // Use the responseProvider for response data
      final responseModel = ref.watch(responseProvider);

      final ResponseModel body = ResponseModel(
        responseBody: responseModel.responseBody,
        messageId: messageId,
      );

      final payload = {
        'responseBody': body.responseBody,
        'messageId': messageId,
      };

      dev.log(name: 'Response payload', payload.toString());
      final response = await dio.post(
        endpoint,
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-type': "application/json",
          },
        ),
      );
      return response;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          throw errorData['message'];
        } else if (errorData is String) {
          throw errorData;
        }
      }
      throw "An error occurred while sending response. Please try again.";
    }
  }

  Future<Response> getMessages([WidgetRef? ref]) async {
    try {
      final baseUrl = dotenv.env['SERVER_BASE_URL'];
      final token = await appServices.readFromSecureStorage('token');
      if (token == null) {
        throw 'Token not found';
      }

      if (baseUrl == null) {
        throw 'The base url is not provided';
      }
      final endpoint = '$baseUrl/community/messages';

      final response = await dio.get(
        endpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          throw errorData['message'];
        } else if (errorData is String) {
          throw errorData;
        }
      }
      throw "An error occurred while getting messages. Please try again.";
    }
  }

  // ----------------------------------------------Like and dislike section
  Future<Response> likeMessage(String messageId, [WidgetRef? ref]) async {
    try {
      final baseUrl = dotenv.env['SERVER_BASE_URL'];
      final token = await appServices.readFromSecureStorage('token');
      if (token == null) {
        throw 'Token not found';
      }

      if (baseUrl == null) {
        throw 'The base url is not provided';
      }
      final endpoint = '$baseUrl/community/like-message';

      final response = await dio.get(
        endpoint,
        queryParameters: {"messageId": messageId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          throw errorData['message'];
        } else if (errorData is String) {
          throw errorData;
        }
      }
      throw "An error occurred while liking the message. Please try again.";
    }
  }

  Future<Response> likeResponse(String responseId, [WidgetRef? ref]) async {
    try {
      final baseUrl = dotenv.env['SERVER_BASE_URL'];
      final token = await appServices.readFromSecureStorage('token');
      if (token == null) {
        throw 'Token not found';
      }

      if (baseUrl == null) {
        throw 'The base url is not provided';
      }
      final endpoint = '$baseUrl/community/like-response';

      final response = await dio.get(
        endpoint,
        queryParameters: {"responseId": responseId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      dev.log(response.toString());
      return response;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          throw errorData['message'];
        } else if (errorData is String) {
          throw errorData;
        }
      }
      throw "An error occurred while liking response. Please try again.";
    }
  }

  Future<Response> disLikeResponse([WidgetRef? ref]) async {
    try {
      final baseUrl = dotenv.env['SERVER_BASE_URL'];
      final token = await appServices.readFromSecureStorage('token');
      if (token == null) {
        throw 'Token not found';
      }

      if (baseUrl == null) {
        throw 'The base url is not provided';
      }
      final endpoint = '$baseUrl/community/messages';

      final response = await dio.get(
        endpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          throw errorData['message'];
        } else if (errorData is String) {
          throw errorData;
        }
      }
      throw "An error occurred while getting messages. Please try again.";
    }
  }

  Future<Response> disLikeMessage(String messageId, [WidgetRef? ref]) async {
    try {
      final baseUrl = dotenv.env['SERVER_BASE_URL'];
      final token = await appServices.readFromSecureStorage('token');
      if (token == null) {
        throw 'Token not found';
      }

      if (baseUrl == null) {
        throw 'The base url is not provided';
      }
      final endpoint = '$baseUrl/community/like-message';

      final response = await dio.get(
        endpoint,
        queryParameters: {"messageId": messageId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          throw errorData['message'];
        } else if (errorData is String) {
          throw errorData;
        }
      }
      throw "An error occurred while liking the message. Please try again.";
    }
  }
}
