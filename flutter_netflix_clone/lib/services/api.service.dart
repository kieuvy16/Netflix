import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_netflix_clone/utils/constants.dart';

class ApiService {
  Future<T> get<T>(
    String endpoint, {
    String? token,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: _buildHeaders(token),
    );
    return _handleResponse(response, fromJson);
  }

  Future<T> post<T>(
    String endpoint,
    dynamic body, {
    String? token,
    T Function(Map<String, dynamic>)? fromJson, required Map<String, String> data,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: _buildHeaders(token),
      body: jsonEncode(body),
    );
    return _handleResponse(response, fromJson);
  }

  Future<T> put<T>(
    String endpoint,
    dynamic body, {
    String? token,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: _buildHeaders(token),
      body: jsonEncode(body),
    );
    return _handleResponse(response, fromJson);
  }

  Future<T> delete<T>(
    String endpoint, {
    String? token,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: _buildHeaders(token),
    );
    return _handleResponse(response, fromJson);
  }

  Map<String, String> _buildHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (fromJson != null) {
        return fromJson(data);
      }
      return data as T;
    } else {
      throw ApiException(
        message: data['message'] ?? 'Unknown error',
        statusCode: response.statusCode,
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}