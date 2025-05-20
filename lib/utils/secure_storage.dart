import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Access Token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: 'access_token');
  }
  // Username
  Future<void> saveUsername(String username) async {
    await _storage.write(key: 'username', value: username);
  }

  Future<String?> getUsername() async {
    return await _storage.read(key: 'username');
  }



  // Email
  Future<void> saveEmail(String email) async {
    await _storage.write(key: 'email', value: email);
  }

  Future<String?> getEmail() async {
    return await _storage.read(key: 'email');
  }
  // Refresh Token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: 'refresh_token');
  }

  // User ID
Future<void> saveUserId(String userId) async {
  await _storage.write(key: 'user_id', value: userId);
}

  Future<String?> getUserId() async {
  return await _storage.read(key: 'user_id');
}
  Future<void> deleteUserId() async{
    await _storage.delete(key: 'user_id');
  }
Future<int?> getStepGoal() async {
    final value = await FlutterSecureStorage().read(key: 'stepGoal');
    return value != null ? int.tryParse(value) : null;
  }

  Future<void> saveStepGoal(int stepGoal) async {
    await FlutterSecureStorage().write(key: 'stepGoal', value: stepGoal.toString());
  }

  Future<int?> getCalorieBurnGoal() async {
    final value = await FlutterSecureStorage().read(key: 'calorieBurnGoal');
    return value != null ? int.tryParse(value) : null;
  }

  Future<void> saveCalorieBurnGoal(int calorieBurnGoal) async {
    await FlutterSecureStorage().write(key: 'calorieBurnGoal', value: calorieBurnGoal.toString());
  }

  Future<double?> getTargetWeight() async {
    final value = await FlutterSecureStorage().read(key: 'targetWeight');
    return value != null ? double.tryParse(value) : null;
  }

  Future<void> saveTargetWeight(double targetWeight) async {
    await FlutterSecureStorage().write(key: 'targetWeight', value: targetWeight.toString());
  }
}