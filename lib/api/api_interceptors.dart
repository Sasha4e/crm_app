// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_crm/storage/token_storage.dart';
import 'package:flutter_crm/pages/login_page.dart';

class ApiInterceptor {
  static Future<http.Response> intercept(http.Request request) async {
    // adding token to every request
    String? accessToken = await TokenStorage.getToken();
    request.headers['Authorization'] = 'Bearer $accessToken';

    // using http.Client
    var client = http.Client();
    var response = await client.send(request);

    var streamedResponse = http.Response.fromStream(response);
    return streamedResponse;
  }
}

class ApiErrorHandler {
  static Future<void> handleResponse(
      http.Response response, BuildContext context) async {
    if (response.statusCode == 401) {
      await TokenStorage.clearToken();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else if (response.statusCode != 200) {
      print('Error: ${response.statusCode}');
      // print('Response body: ${response.body}');
    }
  }
}

class ApiClient {
  static const String baseUrl = 'http://api.stage.newcrm.projects.od.ua/api';

  static Future<http.Response> get(String endpoint) async {
    String? accessToken = await TokenStorage.getToken();
    var url = Uri.parse('$baseUrl/$endpoint');
    return http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  static Future<http.Response> post(
      String endpoint, Map<String, dynamic> data) async {
    String? accessToken = await TokenStorage.getToken();
    var url = Uri.parse('$baseUrl/$endpoint');
    print('REQUEST: POST $url');

    print('BODY: ${json.encode(data)}'); 
    return http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );
  }

  static Future<http.Response> postData(
      String endpoint, Map<String, dynamic> data) async {
    String? accessToken = await TokenStorage.getToken();
    var url = Uri.parse('$baseUrl/$endpoint');
    print('REQUEST: POST $url');

    var request = http.MultipartRequest('POST', url);

    // Добавляем заголовки
    request.headers['Authorization'] = 'Bearer $accessToken';

    // Добавляем данные
    data.forEach((key, value) async {
      if (value is File) {
        // Если значение является файлом, добавляем его как файл
        request.files.add(http.MultipartFile.fromBytes(
          key,
          await value.readAsBytes(),
          filename: value.path.split('/').last,
        ));
      } else {
        // Если значение не файл, добавляем его как текстовое поле
        request.fields[key] = value.toString();
      }
    });

    try {
      // Отправляем запрос и возвращаем результат
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      return response;
    } catch (e) {
      // Если возникает ошибка, печатаем ее
      print('Error: $e');
      throw Exception('Failed to post data: $e');
    }
  }

  static Future<http.Response> put(
      String endpoint, Map<String, dynamic> data) async {
    String? accessToken = await TokenStorage.getToken();
    var url = Uri.parse('$baseUrl/$endpoint');
    print('REQUEST: POST $url');

    print('BODY: ${json.encode(data)}');
    return http.put(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );
  }

  
}
