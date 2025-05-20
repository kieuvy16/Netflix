import 'package:flutter/material.dart';
import 'package:flutter_netflix_clone/models/movie.model.dart';
import 'package:flutter_netflix_clone/services/api.service.dart';
import 'package:flutter_netflix_clone/utils/api.config.dart';

class WatchlistProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<MovieModel> _favorites = [];
  List<MovieModel> _purchasedMovies = [];
  List<MovieModel> _downloads = [];
  bool _isLoading = false;

  List<MovieModel> get favorites => _favorites;
  List<MovieModel> get purchasedMovies => _purchasedMovies;
  List<MovieModel> get downloads => _downloads;
  bool get isLoading => _isLoading;

  Future<void> fetchFavorites(String token) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await _apiService.get<List<MovieModel>>(
        ApiConfig.favorites,
        token: token,
        fromJson: (json) => (json['data'] as List)
            .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      _favorites = response;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPurchasedMovies(String token) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await _apiService.get<List<MovieModel>>(
        ApiConfig.purchasedMovies,
        token: token,
        fromJson: (json) => (json['data'] as List)
            .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      _purchasedMovies = response;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDownloads(String token) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await _apiService.get<List<MovieModel>>(
        ApiConfig.downloads,
        token: token,
        fromJson: (json) => (json['data'] as List)
            .map((e) => MovieModel.fromJson(e['movie'] as Map<String, dynamic>))
            .toList(),
      );
      _downloads = response;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToFavorites(String movieId, String token) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _apiService.post<Map<String, dynamic>>(
        ApiConfig.favorites,
        {
          'movieId': movieId,
        },
        token: token,
        fromJson: (json) => json, data: {},
      );
      final movie = await _apiService.get<MovieModel>(
        ApiConfig.withId(ApiConfig.movieById, movieId),
        token: token,
        fromJson: (json) => MovieModel.fromJson(json['data']),
      );
      _favorites.add(movie);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromFavorites(String movieId, String token) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _apiService.delete<Map<String, dynamic>>(
        '${ApiConfig.favorites}/$movieId',
        token: token,
        fromJson: (json) => json,
      );
      _favorites.removeWhere((movie) => movie.id == movieId);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> purchaseMovie(String userId, String movieId, String token) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _apiService.post<Map<String, dynamic>>(
        ApiConfig.withId(ApiConfig.payment, movieId),
        {
          'userId': userId,
        },
        token: token,
        fromJson: (json) => json, data: {},
      );
      final movie = await _apiService.get<MovieModel>(
        ApiConfig.withId(ApiConfig.movieById, movieId),
        token: token,
        fromJson: (json) => MovieModel.fromJson(json['data']),
      );
      _purchasedMovies.add(movie);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToDownloads(String movieId, String token) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _apiService.post<Map<String, dynamic>>(
        ApiConfig.downloads,
        {
          'movieId': movieId,
        },
        token: token,
        fromJson: (json) => json, data: {},
      );
      final movie = await _apiService.get<MovieModel>(
        ApiConfig.withId(ApiConfig.movieById, movieId),
        token: token,
        fromJson: (json) => MovieModel.fromJson(json['data']),
      );
      _downloads.add(movie);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}