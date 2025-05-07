import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'core/config/env_config.dart';
import 'core/theme/app_theme.dart';
import 'Model/datasources/movie_api_client.dart';
import 'Model/datasources/user_preferences.dart';
import 'Model/repositories/movie_repository_impl.dart';
import 'Model/repositories/movie_repository.dart';
import 'View/pages/splash_screen.dart';
import 'ViewModel/stores/movie_store.dart';
import 'ViewModel/stores/recommendation_store.dart';
import 'ViewModel/stores/user_store.dart';

// Get instance of service locator
final GetIt getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment config
  await EnvConfig.init();
  
  // Set up system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Register dependencies
  await setupDependencies();
  
  runApp(const MyApp());
}

Future<void> setupDependencies() async {
  // Data sources
  getIt.registerSingleton<MovieApiClient>(MovieApiClient());
  getIt.registerSingleton<UserPreferences>(UserPreferences());
  
  // Repositories
  getIt.registerSingleton<MovieRepository>(
    MovieRepositoryImpl(getIt<MovieApiClient>()),
  );
  
  // Stores
  getIt.registerSingleton<MovieStore>(
    MovieStore(getIt<MovieRepository>()),
  );
  
  getIt.registerSingleton<UserStore>(
    UserStore(getIt<UserPreferences>()),
  );
  
  // Register recommendation store (depends on movie store and user store)
  getIt.registerSingleton<RecommendationStore>(
    RecommendationStore(
      movieStore: getIt<MovieStore>(),
      userStore: getIt<UserStore>(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MovieHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

class MovieAppClass {
  static final MovieAppClass _instance = MovieAppClass._internal();
  
  factory MovieAppClass() => _instance;
  
  MovieAppClass._internal();
  
  void initialize(BuildContext context) {
    // Additional initialization if needed
  }
}
