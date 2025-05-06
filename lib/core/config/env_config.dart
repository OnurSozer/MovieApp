import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static late final String apiKey;
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  
  static Future<void> init() async {
    await dotenv.load();
    apiKey = dotenv.env['API_KEY'] ?? '';
  }
} 