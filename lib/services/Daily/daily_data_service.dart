import 'dart:convert';
import 'package:healthharmony/models/Daily/create_daily_food_eat_dto.dart';
import 'package:healthharmony/models/Daily/daily_data_dto.dart';
import 'package:healthharmony/models/Daily/daily_food_dto.dart';
import 'package:healthharmony/services/Auth/auth_service.dart';
import 'package:healthharmony/utils/constants.dart';
import 'package:healthharmony/utils/secure_storage.dart';
import 'package:http/http.dart' as http;

class DailyDataService {
  final String baseUrl = ApiConstants.baseUrl;
  final SecureStorage _secureStorage = SecureStorage();

 Future<DailyDataDTO?> getTodayData() async {
  final token = await _secureStorage.getAccessToken();
  if (token == null) {
    throw Exception('Not authenticated');
  }

  final userId = await _secureStorage.getUserId();
  final response = await http.get(
      Uri.parse('$baseUrl/api/DailyData/today?userId=$userId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    // Eğer veri bulunursa, geri döndür
    return DailyDataDTO.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 401) {
    // Token expired, try to refresh
    final refreshed = await _refreshToken();
    if (refreshed) {
      return getTodayData();
    } else {
      throw Exception('Authentication failed');
    }
  } else if (response.statusCode == 404) {
    // Eğer veri bulunmazsa, yeni veri oluştur
    return await _createAndSaveNewData();
  } else {
    final userId = await _secureStorage.getUserId();
throw Exception('Failed to load daily data $userId');
    
  }
}

Future<DailyDataDTO?> _createAndSaveNewData() async {
  final token = await _secureStorage.getAccessToken();
  if (token == null) {
    throw Exception('Not authenticated');
  }

  // Yeni veri oluştur
  final newData = DailyDataDTO(
    userId: await _secureStorage.getUserId(), // Kullanıcı ID'si alınıyor
    stepCount: 0,  // Varsayılan değerler
    caloriesBurned: 0,
    caloriesConsumed: 0,
    date: DateTime.now(),
  );

  // Yeni veriyi kaydet
  final success = await saveDailyData(newData);

  if (success) {
    return newData; // Yeni veri başarıyla kaydedildiyse, geri döndür
  } else {
    throw Exception('Failed to create new daily data');
  }
}


  Future<bool> saveDailyData(DailyDataDTO dailyData) async {
    final token = await _secureStorage.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/DailyData'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dailyData.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 401) {
      // Token expired, try to refresh
      final refreshed = await _refreshToken();
      if (refreshed) {
        return saveDailyData(dailyData);
      } else {
        throw Exception('Authentication failed');
      }
    } else {
      throw Exception('Failed to save daily data');
    }
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null) {
      return false;
    }

    try {
      final authService = AuthService();
      final result = await authService.refreshToken(refreshToken);
      return result != null;
    } catch (e) {
      return false;
    }
  }

 // Kullanıcının yaktığı kalori bilgisini al
Future<int?> getPendingCaloriesBurned(String? userId) async {
  if (userId == null || userId.isEmpty) {
    throw Exception("User ID is null or empty");
  }

  final token = await _secureStorage.getAccessToken();
  if (token == null) {
    throw Exception('Not authenticated');
  }

  final url = Uri.parse('$baseUrl/api/UserActivity/pending-calories-burn/$userId');

  try {
    print("Fetching pending calories for userId: $userId at $url");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      // Since the response is a raw integer, decode it directly as an int
      final data = int.tryParse(response.body) ?? 0;
      return data; // Return the integer directly
    } else if (response.statusCode == 404) {
      print("No pending calories data found for userId: $userId");
      return 0; // No data found, return 0
    } else if (response.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        return getPendingCaloriesBurned(userId);
      } else {
        throw Exception('Authentication failed');
      }
    } else {
      throw Exception('API error: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to get pending calories: $e');
  }
}

 Future<List<DailyDataDTO>> getLastSixDaysData(String? userId) async {
    if (userId == null || userId.isEmpty) {
      throw Exception("User ID is null or empty");
    }

    final token = await _secureStorage.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final url = Uri.parse('$baseUrl/api/DailyData/$userId/last6days');

    try {
      print("Fetching last six days data for userId: $userId at $url");
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DailyDataDTO.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        print("No data found for userId: $userId");
        return [];
      } else if (response.statusCode == 401) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          return getLastSixDaysData(userId);
        } else {
          throw Exception('Authentication failed');
        }
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get last six days data: $e');
    }
  }
  Future<Map<String, dynamic>?> searchFoodByName(String name) async {
  final token = await _secureStorage.getAccessToken();
  if (token == null) {
    throw Exception('Not authenticated');
  }

  final url = Uri.parse('$baseUrl/api/Food/$name'); // URL endpoint

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  } else if (response.statusCode == 404) {
    return null; // Yemek bulunamadı
  } else if (response.statusCode == 401) {
    final refreshed = await _refreshToken();
    if (refreshed) {
      return searchFoodByName(name);
    } else {
      throw Exception('Authentication failed');
    }
  } else {
    throw Exception('Failed to fetch food data: ${response.statusCode}');
  }
}
Future<bool> addDailyFoodEat(CreateDailyFoodEatDto foodData) async {
    final uri = Uri.parse("$baseUrl/api/Food/addDailyFood");

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(foodData.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Sunucu hatası: ${response.body}");
      }
    } catch (e) {
      throw Exception("İstek hatası: $e");
    }
  }

  Future<List<DailyFoodDto>> getTodayFoods(String? userId) async {
  if (userId == null || userId.isEmpty) {
    throw Exception("User ID is null or empty");
  }

  final token = await _secureStorage.getAccessToken();
  if (token == null) {
    throw Exception('Not authenticated');
  }

  final url = Uri.parse('$baseUrl/api/Food/today/$userId');

  try {
    print("Fetching today's food data for userId: $userId at $url");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => DailyFoodDto.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      print("No food data found for today, userId: $userId");
      return [];
    } else if (response.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        return getTodayFoods(userId); // Retry with new token
      } else {
        throw Exception('Authentication failed');
      }
    } else {
      throw Exception('API error: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to get today\'s food data: $e');
  }
}
}