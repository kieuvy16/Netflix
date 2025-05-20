import 'package:flutter/material.dart';
import 'package:flutter_netflix_clone/models/user.model.dart';
import 'package:flutter_netflix_clone/services/auth.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  bool _isInitialized = false;
  final AuthService _authService = AuthService();

  UserModel? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    if (_isInitialized) {
      return;
    }
    try {
      _isLoading = true;
      _isInitialized = true;
      notifyListeners();
      _token = await _authService.getToken();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (_token != null && userId != null) {
        final response = await _authService.getUser(_token!, userId);
        _user = response;
        if (_user?.avatar != null && _user!.avatar!.isNotEmpty) {
          try {
            base64Decode(_user!.avatar!);
            await prefs.setString('avatar_base64', _user!.avatar!);
          } catch (e) {
          }
        }
      }
    } catch (e) {
      await _authService.logout();
      _token = null;
      _user = null;
      _isInitialized = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String identifier, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      final userData = await _authService.login(identifier, password);
      _user = userData;
      _token = await _authService.getToken();
      _isInitialized = true;
      if (_user == null || _token == null) {
        throw Exception('Đăng nhập thất bại: Thiếu thông tin người dùng hoặc token');
      }
      if (_user?.avatar != null && _user!.avatar!.isNotEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          base64Decode(_user!.avatar!);
          await prefs.setString('avatar_base64', _user!.avatar!);
        } catch (e) {
        }
      }
    } catch (e) {
      await _authService.logout();
      _token = null;
      _user = null;
      _isInitialized = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
    String username,
    String email,
    String password,
    String confirmPassword, {
    String? birthDate,
    String? avatar,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.register(username, email, password, birthDate, avatar);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser({
    String? username,
    String? avatar,
    String? birthDate,
  }) async {
    if (_user == null || _token == null) {
      throw Exception('Không có người dùng hoặc token để cập nhật');
    }
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.updateUser(
        _user!.id,
        _token!,
        username: username,
        avatar: avatar,
        birthDate: birthDate,
        currentUsername: _user!.username,
        currentEmail: _user!.email,
      );
      _user = await _authService.getUser(_token!, _user!.id);
      if (_user?.avatar != null && _user!.avatar!.isNotEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          base64Decode(_user!.avatar!);
          await prefs.setString('avatar_base64', _user!.avatar!);
        } catch (e) {
        }
      }
    } catch (e) {
      if (e.toString().contains('Token không hợp lệ')) {
        await logout();
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.logout();
      _user = null;
      _token = null;
      _isInitialized = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}