import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/Model/entities/movie.dart';
import 'package:movie_app/View/pages/splash_screen.dart';
import 'package:movie_app/ViewModel/stores/movie_store.dart';
import 'package:movie_app/ViewModel/stores/user_store.dart';
import '../mocks/mock_movie_repository.dart';
import '../mocks/mock_user_preferences.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {}
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {}
}

class FakeRoute extends Fake implements Route<dynamic> {}
class FakeMovie extends Fake implements Movie {}
class FakeMovieGenre extends Fake implements MovieGenre {}

void main() {
  late MockMovieRepository mockMovieRepository;
  late MockUserPreferences mockUserPreferences;
  late MovieStore movieStore;
  late UserStore userStore;
  late MockNavigatorObserver navigatorObserver;

  setUpAll(() {
    registerFallbackValue(FakeRoute());
    registerFallbackValue(FakeMovie());
    registerFallbackValue([FakeMovie()]);
    registerFallbackValue(FakeMovieGenre());
    registerFallbackValue([FakeMovieGenre()]);
  });

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    navigatorObserver = MockNavigatorObserver();
    mockMovieRepository = MockMovieRepository();
    mockUserPreferences = MockUserPreferences();
    
    // Reset GetIt before each test
    final getIt = GetIt.instance;
    if (getIt.isRegistered<MovieStore>()) {
      getIt.unregister<MovieStore>();
    }
    if (getIt.isRegistered<UserStore>()) {
      getIt.unregister<UserStore>();
    }
    
    // Set up the stores
    movieStore = MovieStore(mockMovieRepository);
    userStore = UserStore(mockUserPreferences);
    
    // Register them with GetIt
    getIt.registerSingleton<MovieStore>(movieStore);
    getIt.registerSingleton<UserStore>(userStore);

    // Set up the mocks
    when(() => mockUserPreferences.getSelectedGenreIds())
        .thenAnswer((_) async => [28, 12]);
    when(() => mockUserPreferences.isOnboardingCompleted())
        .thenAnswer((_) async => true);
    when(() => mockUserPreferences.getFavoriteMovieIds())
        .thenAnswer((_) async => []);
    when(() => mockUserPreferences.getSubscriptionStatus())
        .thenAnswer((_) async => 'free');
    when(() => mockMovieRepository.getPopularMovies(page: any(named: 'page')))
        .thenAnswer((_) async => TestMovieData.getPopularMovies());
    when(() => mockMovieRepository.getMovieGenres())
        .thenAnswer((_) async => TestMovieData.getGenres());
    when(() => mockMovieRepository.getMoviesByGenre(any()))
        .thenAnswer((_) async => TestMovieData.getPopularMovies());
  });

  tearDown(() {
    // Clean up GetIt after each test
    final getIt = GetIt.instance;
    if (getIt.isRegistered<MovieStore>()) {
      getIt.unregister<MovieStore>();
    }
    if (getIt.isRegistered<UserStore>()) {
      getIt.unregister<UserStore>();
    }
  });

  group('SplashScreen Tests', () {
    testWidgets('SplashScreen should display app logo and name', 
        (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(),
          navigatorObservers: [navigatorObserver],
        ),
      );
      
      // Verify initial state
      expect(find.text('MovieHub'), findsOneWidget);
      
      // Pump a few frames instead of using pumpAndSettle
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      
      // Verify text is still there after animation
      expect(find.text('MovieHub'), findsOneWidget);
    });
  });
}

// Custom widget to wrap test widgets with required dependencies
class TestWrapper extends StatelessWidget {
  final Widget child;
  
  const TestWrapper({Key? key, required this.child}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: child,
    );
  }
} 