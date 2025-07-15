import 'dart:convert';

import 'package:agrinix/models/auth_model.dart';
import 'package:agrinix/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as dev;

class AuthServices {
  final dio = Dio();

  //register service
  Future<Response> registerService(WidgetRef ref) async {
    try {
      final baseUrl = dotenv.env['SERVER_BASE_URL'];

      if (baseUrl == null) {
        throw "Base url not provided.";
      }

      dev.log(baseUrl);
      final provider = ref.watch(authNotifierProvider);

      //get the models for the auth
      final AuthModel authModel = AuthModel(
        email: provider.email,
        name: provider.name ?? "",
        password: provider.password,
      );

      final Map<String, dynamic> payload = {
        'name': authModel.name,
        "email": authModel.email,
        "password": authModel.password,
      };

      // final encodePayload = jsonEncode(payload);

      dev.log(payload.toString(), name: 'Payload');

      //post the data to the server
      final request = await dio.post(
        "$baseUrl/auth/register",
        data: payload,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return request;
    } catch (e) {
      if (e is DioException && e.response != null) {
        dev.log('Error data: ${e.response?.data}', name: 'Register Error');
        // Try to extract a message from the server response
        final errorData = e.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          throw errorData['message'];
        } else if (errorData is String) {
          throw errorData;
        }
      }
      throw "An error occurred while registering for an account.";
    }
  }

  //login service
  Future<Response> loginService(WidgetRef ref) async {
    try {
      final baseUrl = dotenv.env['SERVER_BASE_URL'];

      if (baseUrl == null) {
        throw "Base url not provided.";
      }

      final provider = ref.watch(authNotifierProvider);

      //get the models for the auth
      final AuthModel authModel = AuthModel(
        email: provider.email,
        password: provider.password,
      );

      final Map<String, dynamic> payload = {
        "email": authModel.email,
        "password": authModel.password,
      };

      //post the data to the server
      final request = await dio.post(
        "$baseUrl/auth/login",
        data: payload,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return request;
    } catch (e) {
      dev.log(e.toString());
      if (e is DioException && e.response != null) {
        // Try to extract a message from the server response
        final errorData = e.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          throw errorData['message'];
        } else if (errorData is String) {
          throw errorData;
        }
      }
      throw "An error occurred while logging into account.";
    }
  }
}
