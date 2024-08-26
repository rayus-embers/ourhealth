import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class CustomHttpClient {
  final http.Client client;
  final TokenService tokenService;

  CustomHttpClient({required this.client, required this.tokenService});

  Future<http.Response> request(
      String method,
      Uri url, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    final accessToken = await tokenService.getAccessToken();
    final finalHeaders = {
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      if (headers != null) ...headers,
      'Content-Type': 'application/json',
    };


    if (body != null && finalHeaders['Content-Type'] == 'application/json') {
      body = jsonEncode(body);
    }

    final response = await _sendRequest(() {
      switch (method.toUpperCase()) {
        case 'GET':
          return client.get(url, headers: finalHeaders);
        case 'POST':
          return client.post(url, headers: finalHeaders, body: body);
        case 'PUT':
          return client.put(url, headers: finalHeaders, body: body);
        case 'DELETE':
          return client.delete(url, headers: finalHeaders);
        default:
          throw UnsupportedError('Unsupported HTTP method: $method');
      }
    });

    return response;
  }

  Future<http.Response> _sendRequest(
      Future<http.Response> Function() requestFunction) async {
    final response = await requestFunction();

    if (response.statusCode == 401) {

      bool tokenRefreshed = await _refreshToken();

      if (tokenRefreshed) {
        final accessToken = await tokenService.getAccessToken();
        final responseWithNewToken = await requestFunction();
        return responseWithNewToken;
      }
    }

    return response;
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await tokenService.getRefreshToken();

    if (refreshToken == null) {
      return false;
    }

    final response = await client.post(
      Uri.parse('http://127.0.0.1:8000/api/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newAccessToken = data['access'];
      await tokenService.saveTokens(newAccessToken, refreshToken);
      return true;
    } else {
      await tokenService.logout();
      return false;
    }
  }
  Future<http.StreamedResponse> sendMultipartRequest(http.MultipartRequest request) async {
    final accessToken = await tokenService.getAccessToken();
    if (accessToken != null) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode == 401) {
      bool tokenRefreshed = await _refreshToken();

      if (tokenRefreshed) {
        final newAccessToken = await tokenService.getAccessToken();
        if (newAccessToken != null) {
          request.headers['Authorization'] = 'Bearer $newAccessToken';
        }
        return request.send();
      }
    }

    return streamedResponse;
  }
}
