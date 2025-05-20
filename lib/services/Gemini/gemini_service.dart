import 'package:healthharmony/utils/constants.dart';
import 'package:http/http.dart' as http;


class GeminiService {
  final String _baseUrl = ApiConstants.baseUrl;

  Future<String> askGemini(String prompt) async {
    final url = Uri.parse('$_baseUrl/api/Gemini/ask?prompt=$prompt');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Sunucu hatası: ${response.statusCode}');
    }
  }
}
