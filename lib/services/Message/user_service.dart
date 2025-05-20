import 'dart:convert';
import 'package:healthharmony/models/User/user_message.dart';
import 'package:healthharmony/utils/constants.dart';
import 'package:http/http.dart' as http;

class UserService {
  final baseUrl = ApiConstants.baseUrl;

  // Anahtar kelimeye göre kullanıcı ara
  Future<List<User>> searchUsers(String keyword) async {
    final url = Uri.parse('$baseUrl/users/search?keyword=$keyword');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Kullanıcılar alınamadı');
    }
  }

  // Belirli ID’lere göre kullanıcıları getir (isteğe bağlı API)
  Future<List<User>> getUsersByIds(List<String> userIds) async {
    final url = Uri.parse('$baseUrl/users/byids');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userIds),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Kullanıcılar alınamadı');
    }
  }
}
