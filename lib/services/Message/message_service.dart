import 'dart:convert';
import 'package:healthharmony/models/Message/MessageCreateDTO%20.dart';
import 'package:http/http.dart' as http;


class MessageService {
  final String baseUrl = "https://10.0.2.2:7040'/api/Messages"; // API base url

  Future<void> sendMessage(MessageCreateDTO message) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(message.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to send message");
    }
  }

  Future<List<MessageCreateDTO>> getMessages(String senderId, String receiverId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$senderId/$receiverId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MessageCreateDTO.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load messages");
    }
  }
}
