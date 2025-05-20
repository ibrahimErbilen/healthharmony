import 'dart:convert';
import 'package:healthharmony/models/Token/refresh_token_request_dto.dart';
import 'package:healthharmony/models/Token/token.dart';
import 'package:healthharmony/models/User/user_create_dto.dart';
import 'package:healthharmony/models/User/user_login_dto.dart';
import 'package:healthharmony/utils/constants.dart';
import 'package:healthharmony/utils/secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = ApiConstants.baseUrl;
  final SecureStorage _secureStorage = SecureStorage();
Future<TokenResponse?> login(UserLoginDto loginDto) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loginDto.toJson()),
    );

    if (response.statusCode == 200) {
      // Yanıtı alıyoruz
      final responseBody = jsonDecode(response.body);
      
      // TokenResponse ve diğer verileri çıkarıyoruz
      final tokenResponse = TokenResponse.fromJson(responseBody);
      final userId = responseBody['userId'];
      final username = responseBody['username'];
      final email = responseBody['email'];
      final token = responseBody['token'];
      final refreshToken = responseBody['refreshToken'];

      // Verileri güvenli alanda saklıyoruz
      await _secureStorage.saveUserId(userId);  // userId
      await _secureStorage.saveUsername(username);  // username
      await _secureStorage.saveEmail(email);  // email
      await _secureStorage.saveAccessToken(token);  // accessToken
      await _secureStorage.saveRefreshToken(refreshToken);  // refreshToken

      return tokenResponse;
    } else {
      // Hata durumunda null döndürüyoruz
      return null;
    }
  } catch (e) {
    print('Login error: $e');
    return null;
  }
}


  Future<bool> register(UserCreateDto registerDto) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(registerDto.toJson()),
    );

    return response.statusCode == 200;
  }

  Future<TokenResponse?> refreshToken(String refreshToken) async {
    final dto = RefreshTokenRequestDto(refreshToken: refreshToken);
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/Auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      final tokenResponse = TokenResponse.fromJson(jsonDecode(response.body));
      
      // Save new tokens to secure storage
      await _secureStorage.saveAccessToken(tokenResponse.accessToken);
      await _secureStorage.saveRefreshToken(tokenResponse.refreshToken);
      
      return tokenResponse;
    } else {
      return null;
    }
  }

  Future<void> logout() async {
    await _secureStorage.deleteAccessToken();
    await _secureStorage.deleteRefreshToken();
  }
}
