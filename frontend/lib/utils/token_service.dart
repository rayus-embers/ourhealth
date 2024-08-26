import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TokenService {
  final storage = FlutterSecureStorage();

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await storage.write(key: 'accessToken', value: accessToken);
    await storage.write(key: 'refreshToken', value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: 'accessToken');
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: 'refreshToken');

  }

  Future<void> refreshToken() async {
    final refreshToken = await getRefreshToken();

    if (refreshToken != null) {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/token/refresh/'),
        body: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access'];
        await saveTokens(newAccessToken, refreshToken);
      } else {
        print('Failed to refresh token');
      }
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');
  }

  Future<http.Response> makeAuthenticatedRequest(String url) async {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception("Access token is null");
    }
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 401) {
      await refreshToken();
      accessToken = await getAccessToken();

      return await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
    }

    return response;
  }
}
