import 'package:flutter/material.dart';
import 'package:flutter_netflix_clone/models/genre.model.dart';
import 'package:flutter_netflix_clone/models/movie.model.dart';
import 'package:flutter_netflix_clone/services/api.service.dart';
import 'package:flutter_netflix_clone/utils/api.config.dart';
import 'dart:math';

class MovieProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<MovieModel> _movies = [];
  List<GenreModel> _genres = [];
  List<MovieModel> _freeMovies = [];
  MovieModel? _randomFreeMovie;
  bool _isLoading = false;

  List<MovieModel> get movies => _movies;
  List<GenreModel> get genres => _genres;
  List<MovieModel> get freeMovies => _freeMovies;
  MovieModel? get randomFreeMovie => _randomFreeMovie;
  bool get isLoading => _isLoading;

  Future<void> fetchMovies() async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await _apiService.get<List<MovieModel>>(
        ApiConfig.movies,
        fromJson: (json) => (json['data'] as List)
            .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      _movies = response;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchGenres() async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await _apiService.get<List<GenreModel>>(
        ApiConfig.genres,
        fromJson: (json) => (json['data'] as List)
            .map((e) => GenreModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      _genres = response;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<MovieModel>> fetchMoviesByGenre(String genreId) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await _apiService.get<List<MovieModel>>(
        '${ApiConfig.movies}/genre/$genreId',
        fromJson: (json) => (json['data'] as List)
            .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return response;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<MovieModel>> searchMovies(String title) async {
    try {
      _isLoading = true;
      notifyListeners();
      final encodedTitle = Uri.encodeQueryComponent(title);
      final response = await _apiService.get<List<MovieModel>>(
        '${ApiConfig.searchMovies}?title=$encodedTitle',
        fromJson: (json) => (json['data'] as List)
            .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return response;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<MovieModel> fetchMovieById(String id, {String? token}) async {
    try {
      _isLoading = true;
      notifyListeners();
      return await _apiService.get<MovieModel>(
        ApiConfig.withId(ApiConfig.movieById, id),
        token: token,
        fromJson: (json) => MovieModel.fromJson(json['data']),
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFreeMovies() async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await _apiService.get<List<MovieModel>>(
        ApiConfig.movies,
        fromJson: (json) => (json['data'] as List)
            .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      _freeMovies = response.where((movie) => !movie.isPaid).toList();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRandomFreeMovie() async {
    try {
      _isLoading = true;
      notifyListeners();
      if (_freeMovies.isEmpty) {
        await fetchFreeMovies();
      }
      if (_freeMovies.isNotEmpty) {
        final random = Random();
        _randomFreeMovie = _freeMovies[random.nextInt(_freeMovies.length)];
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}