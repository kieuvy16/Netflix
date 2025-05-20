import 'package:flutter/material.dart';
import 'package:flutter_netflix_clone/models/comment.model.dart';
import 'package:flutter_netflix_clone/services/api.service.dart';
import 'package:flutter_netflix_clone/utils/api.config.dart';

class CommentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<CommentModel> _comments = [];
  bool _isLoading = false;

  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;

  Future<void> fetchCommentsByMovie(String movieId) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await _apiService.get<List<CommentModel>>(
        ApiConfig.withId(ApiConfig.commentsByMovie, movieId),
        fromJson: (json) => (json['data'] as List)
            .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      _comments = response;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createComment(String movieId, String content, String token) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.comments,
        {
          'movieId': movieId,
          'content': content,
        },
        token: token,
        fromJson: (json) => json, data: {},
      );
      final newComment = CommentModel.fromJson(response['data']);
      _comments.add(newComment);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateComment(String commentId, String content, String token) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await _apiService.put<Map<String, dynamic>>(
        ApiConfig.withId(ApiConfig.commentById, commentId),
        {
          'content': content,
        },
        token: token,
        fromJson: (json) => json,
      );
      final updatedComment = CommentModel.fromJson(response['data']);
      final index = _comments.indexWhere((comment) => comment.id == commentId);
      if (index != -1) {
        _comments[index] = updatedComment;
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteComment(String commentId, String token) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _apiService.delete<Map<String, dynamic>>(
        ApiConfig.withId(ApiConfig.commentById, commentId),
        token: token,
        fromJson: (json) => json,
      );
      _comments.removeWhere((comment) => comment.id == commentId);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}