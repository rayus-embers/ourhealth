import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../utils/token_service.dart';

class AuthService {
  Future<void> login(BuildContext context, String username, String password) async {
    final tokenService = Provider.of<TokenService>(context, listen: false);

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/token/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access']);
        await tokenService.saveTokens(data['access'], data['refresh']);
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        throw Exception('Login failed: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<void> registerAndLogin(BuildContext context, String username, String password, bool gender) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/core/register/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'username': username,
          'password': password,
          'gender': gender,
        }),
      );

      if (response.statusCode == 200) {
        await login(context, username, password);
      } else {
        throw Exception('Registration failed: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
