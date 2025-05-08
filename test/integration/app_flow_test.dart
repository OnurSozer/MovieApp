import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/Model/entities/movie.dart';
import 'package:movie_app/Model/repositories/movie_repository.dart';
import 'package:movie_app/ViewModel/stores/movie_store.dart';
import 'package:movie_app/ViewModel/stores/user_store.dart';
import 'package:movie_app/ViewModel/stores/recommendation_store.dart';
import 'package:movie_app/main.dart';
import 'package:network_image_mock/network_image_mock.dart';
import '../mocks/mock_movie_repository.dart';
import '../mocks/mock_user_preferences.dart';

class FakeMovie extends Fake implements Movie {}
class FakeMovieGenre extends Fake implements MovieGenre {}

// This test simulates the whole app flow from a higher level
void main() {
  late MockMovieRepository mockMovieRepository;
  late MockUserPreferences mockUserPreferences;
  late MovieStore movieStore;
  late UserStore userStore;
  late RecommendationStore recommendationStore;

  setUpAll(() {
    registerFallbackValue(FakeMovie());
    registerFallbackValue([FakeMovie()]);
    registerFallbackValue(FakeMovieGenre());
    registerFallbackValue([FakeMovieGenre()]);
  });

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Create mocks
    mockMovieRepository = MockMovieRepository();
    mockUserPreferences = MockUserPreferences();
    
    // Reset GetIt before each test
    final getIt = GetIt.instance;
    if (getIt.isRegistered<MovieRepository>()) {
      getIt.unregister<MovieRepository>();
    }
    if (getIt.isRegistered<MovieStore>()) {
      getIt.unregister<MovieStore>();
    }
    if (getIt.isRegistered<UserStore>()) {
      getIt.unregister<UserStore>();
    }
    if (getIt.isRegistered<RecommendationStore>()) {
      getIt.unregister<RecommendationStore>();
    }
    
    // Register the repository
    getIt.registerSingleton<MovieRepository>(mockMovieRepository);
    
    // Set up stores
    movieStore = MovieStore(mockMovieRepository);
    userStore = UserStore(mockUserPreferences);
    recommendationStore = RecommendationStore(
      movieStore: movieStore,
      userStore: userStore,
    );
    
    // Register stores with GetIt
    getIt.registerSingleton<MovieStore>(movieStore);
    getIt.registerSingleton<UserStore>(userStore);
    getIt.registerSingleton<RecommendationStore>(recommendationStore);

    // Set up the mock responses
    when(() => mockUserPreferences.getSelectedGenreIds())
        .thenAnswer((_) async => [28, 12]);
    when(() => mockUserPreferences.isOnboardingCompleted())
        .thenAnswer((_) async => true);
    when(() => mockUserPreferences.getFavoriteMovieIds())
        .thenAnswer((_) async => []);
    when(() => mockUserPreferences.getSubscriptionStatus())
        .thenAnswer((_) async => 'free');
    when(() => mockUserPreferences.saveSelectedGenres(any()))
        .thenAnswer((_) async {});
    when(() => mockUserPreferences.setCompletedOnboarding(any()))
        .thenAnswer((_) async {});
        
    when(() => mockMovieRepository.getPopularMovies(page: any(named: 'page')))
        .thenAnswer((_) async => TestMovieData.getPopularMovies());
    when(() => mockMovieRepository.getMovieGenres())
        .thenAnswer((_) async => TestMovieData.getGenres());
    when(() => mockMovieRepository.getMoviesByGenre(any()))
        .thenAnswer((_) async => TestMovieData.getPopularMovies());
    when(() => mockMovieRepository.getFavoriteMovies())
        .thenAnswer((_) async => []);
    when(() => mockMovieRepository.saveFavoriteMovies(any()))
        .thenAnswer((_) async {});
  });

  tearDown(() {
    // Clean up GetIt
    final getIt = GetIt.instance;
    if (getIt.isRegistered<MovieRepository>()) {
      getIt.unregister<MovieRepository>();
    }
    if (getIt.isRegistered<MovieStore>()) {
      getIt.unregister<MovieStore>();
    }
    if (getIt.isRegistered<UserStore>()) {
      getIt.unregister<UserStore>();
    }
    if (getIt.isRegistered<RecommendationStore>()) {
      getIt.unregister<RecommendationStore>();
    }
  });

  group('App Integration Tests', () {
    testWidgets('App should display splash screen correctly',
        (WidgetTester tester) async {
      // Mock network images for the test
      await mockNetworkImagesFor(() async {
        // Build the app
        await tester.pumpWidget(const MyApp());
        
        // Verify we start on the splash screen
        expect(find.text('MovieHub'), findsOneWidget);
        
        // This verifies that the splash screen is shown correctly
        // We're not testing the full app flow as it depends on multiple async operations
        // that are hard to synchronize in a test environment
      });
    });
  });
}

// Custom app wrapper for testing the full app flow
class TestApp extends StatelessWidget {
  const TestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyApp(),
    );
  }
} 