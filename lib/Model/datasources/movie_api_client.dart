import 'package:dio/dio.dart';
import '../../core/config/env_config.dart';

class MovieApiClient {
  late final Dio _dio;
  
  MovieApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: EnvConfig.baseUrl,
      headers: {
        'Authorization': 'Bearer ${EnvConfig.apiKey}',
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    
    // Add request logger for development purposes
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }
  
  Future<Response> getPopularMovies({int page = 1}) {
    return _dio.get('/movie/popular', queryParameters: {'page': page});
  }
  
  Future<Response> getMovieDetails(int movieId) {
    return _dio.get('/movie/$movieId');
  }
  
  Future<Response> searchMovies(String query) {
    return _dio.get('/search/movie', queryParameters: {'query': query});
  }
  
  Future<Response> getMoviesByGenre(int genreId) {
    // Request more movies to ensure we get at least 9 valid ones
    // Some movies might be missing posters or have other issues
    return _dio.get('/discover/movie', queryParameters: {
      'with_genres': genreId,
      'page': 1,
      'per_page': 20 // Request more to ensure we get at least 9 good ones
    });
  }
  
  Future<Response> getMovieGenres() {
    return _dio.get('/genre/movie/list');
  }
} 