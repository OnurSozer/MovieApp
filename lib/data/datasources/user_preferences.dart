import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/movie.dart';

class UserPreferences {
  static const String _kFavoriteMoviesKey = 'favorite_movies';
  static const String _kSelectedGenresKey = 'selected_genres';
  static const String _kCompletedOnboardingKey = 'completed_onboarding';
  static const String _kSubscriptionStatusKey = 'subscription_status';
  
  // Singleton pattern
  static final UserPreferences _instance = UserPreferences._internal();
  
  factory UserPreferences() => _instance;
  
  UserPreferences._internal();
  
  // Save favorite movies
  Future<void> saveFavoriteMovies(List<Movie> movies) async {
    final prefs = await SharedPreferences.getInstance();
    final moviesJson = movies.map((movie) => {
      'id': movie.id,
      'title': movie.title,
      'posterPath': movie.posterPath,
      'releaseDate': movie.releaseDate,
    }).toList();
    await prefs.setString(_kFavoriteMoviesKey, jsonEncode(moviesJson));
  }
  
  // Get favorite movies
  Future<List<int>> getFavoriteMovieIds() async {
    final prefs = await SharedPreferences.getInstance();
    final moviesString = prefs.getString(_kFavoriteMoviesKey);
    if (moviesString == null) {
      return [];
    }
    
    final List<dynamic> moviesJson = jsonDecode(moviesString);
    return moviesJson.map<int>((movie) => movie['id'] as int).toList();
  }
  
  // Save selected genres
  Future<void> saveSelectedGenres(List<MovieGenre> genres) async {
    final prefs = await SharedPreferences.getInstance();
    final genresJson = genres.map((genre) => {
      'id': genre.id,
      'name': genre.name,
    }).toList();
    await prefs.setString(_kSelectedGenresKey, jsonEncode(genresJson));
  }
  
  // Get selected genres
  Future<List<int>> getSelectedGenreIds() async {
    final prefs = await SharedPreferences.getInstance();
    final genresString = prefs.getString(_kSelectedGenresKey);
    if (genresString == null) {
      return [];
    }
    
    final List<dynamic> genresJson = jsonDecode(genresString);
    return genresJson.map<int>((genre) => genre['id'] as int).toList();
  }
  
  // Set onboarding completion status
  Future<void> setCompletedOnboarding(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCompletedOnboardingKey, completed);
  }
  
  // Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kCompletedOnboardingKey) ?? false;
  }
  
  // Set subscription status
  Future<void> setSubscriptionStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSubscriptionStatusKey, status);
  }
  
  // Get subscription status
  Future<String> getSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kSubscriptionStatusKey) ?? 'free';
  }
  
  // Clear all preferences
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
} 