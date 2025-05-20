import 'dart:convert';
import 'package:healthharmony/models/Activity/activitiy_succes.dart';
import 'package:healthharmony/models/Activity/activity_dto.dart';
import 'package:healthharmony/models/Activity/user_activity_dto.dart';
import 'package:healthharmony/utils/constants.dart';
import 'package:healthharmony/utils/secure_storage.dart';
import 'package:http/http.dart' as http;

class ActivityService {
  final String baseUrl = ApiConstants.baseUrl;
  final SecureStorage _secureStorage = SecureStorage();

  Future<String?> _getAuthToken() async {
    final token = await _secureStorage.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    return token;
  }

  Future<List<ActivityDTO>> getActivities() async {
    final token = await _getAuthToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/Activity'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ActivityDTO.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load activities');
    }
  }

Future<List<UserActivityDTO>> getUserActivities() async {
  try {
    final token = await _getAuthToken();
    final userId = await _secureStorage.getUserId();

    if (userId == null) {
      throw Exception('User ID not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/UserActivity/by-user/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => UserActivityDTO.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load user activities');
    }
  } catch (e) {
    throw Exception('An error occurred while fetching user activities: ${e.toString()}');
  }
}

Future<bool> addUserActivity(ActivityDTO activity) async {
  try {
    final token = await _getAuthToken();
    final userId = await _secureStorage.getUserId();
    
    if (userId == null) {
      throw Exception('User ID not found');
    }
    
    final now = DateTime.now().toIso8601String();
    
    // Make sure activity.activityName and activity.description are not null
    final activityName = activity.activityName ?? '';
    final description = activity.description ?? '';
    
    final body = {
      'userId': userId,
      'activityId': activity.activityId,
      'activityName': activityName,
      'description': description,
      'addedDate': now,
      'completionDate':  null,
      'isCompleted': false,
    };
    
    print('Sending request to API: ${jsonEncode(body)}');
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/UserActivity'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print('Error response: ${response.body}');
      throw Exception('Aktivite eklenirken hata oluştu. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception during API call: ${e.toString()}');
    throw Exception('Aktivite eklenirken bir hata oluştu: ${e.toString()}');
  }
}


Future<bool> toggleActivityCompletion(UserActivityDTO activity) async {
  try {
    print('toggleActivityCompletion başladı - activity ID: ${activity.userActivityId}');

    // --- Input Data Type Check (Crucial Debugging) ---
    print('Input activity.addedDate type: ${activity.addedDate.runtimeType}');
    print('Input activity.completionDate type: ${activity.completionDate?.runtimeType}');

    final token = await _getAuthToken();
    print('Token alındı.');

    if (token == null) {
      print('Hata: Token alınamadı');
      throw Exception('Token alınamadı');
    }

    final uri = Uri.parse('$baseUrl/api/UserActivity/UpdateActivity/${activity.userActivityId}');
    print('İstek URL: $uri');

    // --- Prepare Date Strings Safely ---

    // 1. Handle addedDate: Convert if DateTime, otherwise use as is (assuming String or null)
    String? addedDateString;
     addedDateString = (activity.addedDate as DateTime).toIso8601String();
     print('Converted activity.addedDate (DateTime) to String: $addedDateString');
  

    // 2. Handle completionDate: Set to now() if completing, otherwise null.
    //    (You mentioned sending null is okay, this simplifies the logic)
    String? completionDateString;
    bool isCompleting = !activity.isCompleted; // The target state

    if (isCompleting) {
      // If marking as complete, set completion date string
      completionDateString = DateTime.now().toIso8601String();
      print('Setting completionDateString for completion: $completionDateString');
    } else {
      // If marking as incomplete, set completion date string to null
      completionDateString = null;
      print('Setting completionDateString to null (marking incomplete).');
    }
    // Note: This overwrites any existing completion date when marking incomplete.
    // If you needed to preserve it, you'd handle activity.completionDate like addedDate.


    // --- Build the Request Body Map ---
    final Map<String, dynamic> requestBody = {
      "userActivityId": activity.userActivityId,
      "userId": activity.userId,
      "activityId": activity.activityId,

      // *** Use the safely prepared String? values ***
      "addedDate": addedDateString,
      "completionDate": completionDateString,

      "isCompleted": isCompleting, // Send the NEW toggled value
      "activityName": activity.activityName,
      "description": activity.description
      // Add any other fields required by the backend model, ensuring they are JSON-encodable
    };

    // --- Pre-Encoding Check (Debugging) ---
    print('Map to be encoded:');
    requestBody.forEach((key, value) {
      print('  Key: $key, Value Type: ${value?.runtimeType}, Value: $value'); // Check types here!
    });

    // Remove null values *after* inspection if needed by backend
    requestBody.removeWhere((key, value) => value == null);
    print('Map after removing nulls: $requestBody');


    // --- Encode and Send ---
    final encodedBody = jsonEncode(requestBody); // <--- This should now work
    print('Gönderilen JSON body: $encodedBody');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: encodedBody,
    );

    print('Yanıt alındı - Kod: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('Aktivite başarıyla güncellendi (ID: ${activity.userActivityId}).');
      return true;
    } else {
      print(
          'Aktivite güncellenemedi: ${response.statusCode} - Yanıt: ${response.body} - Gönderilen ID: ${activity.userActivityId}');
      throw Exception(
          'Aktivite güncellenemedi: ${response.statusCode}');
    }
  } catch (e, stackTrace) { // Include stackTrace for better debugging
    print('toggleActivityCompletion Hata: $e');
    print('Stack Trace: $stackTrace'); // Print stack trace
    throw Exception('Aktivite güncellenirken bir hata oluştu: $e');
  }
}}