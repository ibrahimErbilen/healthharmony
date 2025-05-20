import 'dart:convert';

import 'package:healthharmony/models/Coach/Coach.dart';
import 'package:healthharmony/utils/constants.dart';
import 'package:http/http.dart' as http;

class CoachService {
  Future<Coach?> getCoachByInvitationCode(String code) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/Coach/get-by-invitation-code/$code');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Coach.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      return null; // Koç bulunamadı
    } else {
      throw Exception('API hatası: ${response.statusCode}');
    }
  }
}