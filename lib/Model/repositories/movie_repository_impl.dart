import 'package:dio/dio.dart';
import '../../Model/entities/movie.dart';
import '../../Model/repositories/movie_repository.dart';
import '../datasources/movie_api_client.dart';
import '../models/movie_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MovieRepositoryImpl implements MovieRepository {
  final MovieApiClient _apiClient;
  
  MovieRepositoryImpl(this._apiClient);
  
  @override
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      final response = await _apiClient.getPopularMovies(page: page);
      final List<dynamic> results = response.data['results'];
      return results
          .map((movieJson) => MovieModel.fromJson(movieJson))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<List<MovieGenre>> getMovieGenres() async {
    try {
      final response = await _apiClient.getMovieGenres();
      final List<dynamic> genres = response.data['genres'];
      return genres
          .map((genreJson) => MovieGenreModel.fromJson(genreJson))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<List<Movie>> getMoviesByGenre(int genreId) async {
    try {
      final response = await _apiClient.getMoviesByGenre(genreId);
      final List<dynamic> results = response.data['results'];
      return results
          .map((movieJson) => MovieModel.fromJson(movieJson))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<Movie> getMovieDetails(int movieId) async {
    try {
      final response = await _apiClient.getMovieDetails(movieId);
      return MovieModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await _apiClient.searchMovies(query);
      final List<dynamic> results = response.data['results'];
      return results
          .map((movieJson) => MovieModel.fromJson(movieJson))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<List<Movie>> getFavoriteMovies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString('favorite_movies');
      
      if (favoritesJson == null || favoritesJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> decodedList = jsonDecode(favoritesJson);
      return decodedList
          .map((movieJson) => MovieModel.fromJson(movieJson))
          .toList();
    } catch (e) {
      print('Error loading favorites: $e');
      return [];
    }
  }
  
  @override
  Future<void> saveFavoriteMovies(List<Movie> movies) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> moviesJsonList = movies
          .map((movie) => (movie as MovieModel).toJson())
          .toList();
      
      await prefs.setString('favorite_movies', jsonEncode(moviesJsonList));
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }
  
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return Exception('Connection timeout. Please check your internet connection.');
      } else if (error.response != null) {
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return Exception('Unauthorized. Please check your API key.');
        } else if (statusCode == 404) {
          return Exception('Resource not found.');
        } else {
          return Exception('API Error: ${error.response?.statusMessage ?? "Unknown error"}');
        }
      }
    }
    return Exception('An unexpected error occurred: ${error.toString()}');
  }
} 