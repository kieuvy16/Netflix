import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_netflix_clone/services/api.service.dart';
import 'package:flutter_netflix_clone/models/user.model.dart';
import 'package:flutter_netflix_clone/utils/api.config.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<UserModel> login(String identifier, String password) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.login,
        {'identifier': identifier, 'password': password},
        fromJson: (json) => json, data: {},
      );
      if (response['data'] == null || response['data']['token'] == null || response['data']['user'] == null) {
        throw Exception('Phản hồi API không hợp lệ: Thiếu token hoặc user');
      }
      final token = response['data']['token'] as String;
      final userData = response['data']['user'] as Map<String, dynamic>;
      
      if (userData['id'] == null || userData['username'] == null || userData['email'] == null || userData['role'] == null) {
        throw Exception('Dữ liệu user không hợp lệ: Thiếu trường bắt buộc');
      }
      await _saveToken(token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userData['id'].toString());
      final user = UserModel.fromJson({
        '_id': userData['id'].toString(),
        'username': userData['username'],
        'email': userData['email'],
        'role': userData['role'],
        'birthDate': userData['birthDate'],
        'avatar': userData['avatar'],
        'watchLater': List<String>.from(userData['watchLater'] ?? []),
        'favorites': List<String>.from(userData['favorites'] ?? []),
        'purchasedMovies': List<String>.from(userData['purchasedMovies'] ?? []),
        'preferences': List<String>.from(userData['preferences'] ?? []),
        'isActive': userData['isActive'] ?? true,
      });
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String username, String email, String password, [String? birthDate, String? avatar]) async {
    try {
      final body = {
        'username': username,
        'email': email,
        'password': password,
        'confirmPassword': password,
      };
      if (birthDate != null) body['birthDate'] = birthDate;
      if (avatar != null) body['avatar'] = avatar;

      await _apiService.post<Map<String, dynamic>>(
        ApiConfig.register,
        body,
        fromJson: (json) => json, data: {},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getUser(String token, String userId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConfig.withId('/api/user/:id', userId),
        token: token,
        fromJson: (json) => json['data'],
      );
      final user = UserModel.fromJson(response);
      return user;
    } catch (e) {
      throw Exception('Không thể lấy thông tin người dùng: $e');
    }
  }

  Future<void> updateUser(
    String userId,
    String token, {
    String? username,
    String? avatar,
    String? birthDate,
    required String currentUsername,
    required String currentEmail,
  }) async {
    final updates = {};
    if (username != null && username.isNotEmpty) updates['username'] = username;
    if (avatar != null && avatar.isNotEmpty) updates['avatar'] = avatar;
    if (birthDate != null && birthDate.isNotEmpty) updates['birthDate'] = birthDate;

    if (updates.isEmpty) {
      return;
    }

    try {
      await _apiService.put<Map<String, dynamic>>(
        ApiConfig.withId('/api/user/:id', userId),
        updates,
        token: token,
        fromJson: (json) => json,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}