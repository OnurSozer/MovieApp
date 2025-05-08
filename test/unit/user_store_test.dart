import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/Model/entities/movie.dart';
import 'package:movie_app/ViewModel/stores/user_store.dart';
import '../mocks/mock_user_preferences.dart';

class FakeList<T> extends Fake implements List<T> {}

void main() {
  late MockUserPreferences mockPreferences;
  late UserStore userStore;

  setUpAll(() {
    registerFallbackValue(FakeList<MovieGenre>());
  });

  setUp(() {
    mockPreferences = MockUserPreferences();
    userStore = UserStore(mockPreferences);
  });

  group('UserStore Tests', () {
    test('initPreferences should load user settings on success', () async {
      // Arrange
      when(() => mockPreferences.getSelectedGenreIds())
          .thenAnswer((_) async => [28, 12]);
      when(() => mockPreferences.isOnboardingCompleted())
          .thenAnswer((_) async => true);
      when(() => mockPreferences.getFavoriteMovieIds())
          .thenAnswer((_) async => [101, 102]);
      when(() => mockPreferences.getSubscriptionStatus())
          .thenAnswer((_) async => 'free');
      
      // Act
      await userStore.initPreferences();
      
      // Assert
      expect(userStore.selectedGenreIds.length, 2);
      expect(userStore.selectedGenreIds.contains(28), true);
      expect(userStore.selectedGenreIds.contains(12), true);
      expect(userStore.isOnboardingCompleted, true);
      verify(() => mockPreferences.getSelectedGenreIds()).called(1);
      verify(() => mockPreferences.isOnboardingCompleted()).called(1);
    });

    test('addSelectedGenre should add genre to preferences', () async {
      // Arrange
      const genreId = 16;
      when(() => mockPreferences.saveSelectedGenres(any()))
          .thenAnswer((_) async {});
      
      // Act
      await userStore.addSelectedGenre(genreId);
      
      // Assert
      expect(userStore.selectedGenreIds.length, 1);
      expect(userStore.selectedGenreIds.contains(genreId), true);
      verify(() => mockPreferences.saveSelectedGenres(any())).called(1);
    });

    test('completeOnboarding should mark onboarding as completed', () async {
      // Arrange
      when(() => mockPreferences.setCompletedOnboarding(any()))
          .thenAnswer((_) async {});
      
      // Act
      await userStore.completeOnboarding();
      
      // Assert
      expect(userStore.isOnboardingCompleted, true);
      verify(() => mockPreferences.setCompletedOnboarding(true)).called(1);
    });

    test('addSelectedGenre should add genreId when not in selected list', () async {
      // Arrange
      const genreId = 28;
      userStore = UserStore(mockPreferences); // Start with empty selection
      when(() => mockPreferences.saveSelectedGenres(any()))
          .thenAnswer((_) async {});
      
      // Act
      await userStore.addSelectedGenre(genreId);
      
      // Assert
      expect(userStore.selectedGenreIds.length, 1);
      expect(userStore.selectedGenreIds.contains(genreId), true);
    });

    test('removeSelectedGenre should remove genreId when already in selected list', () async {
      // Arrange
      const genreId = 28;
      when(() => mockPreferences.getSelectedGenreIds())
          .thenAnswer((_) async => [genreId]);
      when(() => mockPreferences.getFavoriteMovieIds())
          .thenAnswer((_) async => []);
      when(() => mockPreferences.getSubscriptionStatus())
          .thenAnswer((_) async => 'free');
      when(() => mockPreferences.isOnboardingCompleted())
          .thenAnswer((_) async => false);
      when(() => mockPreferences.saveSelectedGenres(any()))
          .thenAnswer((_) async {});
      await userStore.initPreferences(); // Start with genreId already selected
      
      // Act
      await userStore.removeSelectedGenre(genreId);
      
      // Assert
      expect(userStore.selectedGenreIds.length, 0);
      expect(userStore.selectedGenreIds.contains(genreId), false);
    });

    test('toggleSelectedGenre should toggle genre selection state', () async {
      // Arrange
      const genreId = 28;
      when(() => mockPreferences.getSelectedGenreIds())
          .thenAnswer((_) async => []);
      when(() => mockPreferences.getFavoriteMovieIds())
          .thenAnswer((_) async => []);
      when(() => mockPreferences.getSubscriptionStatus())
          .thenAnswer((_) async => 'free');
      when(() => mockPreferences.isOnboardingCompleted())
          .thenAnswer((_) async => false);
      when(() => mockPreferences.saveSelectedGenres(any()))
          .thenAnswer((_) async {});
      await userStore.initPreferences();
      
      // Act & Assert - First toggle adds
      await userStore.toggleSelectedGenre(genreId);
      expect(userStore.selectedGenreIds.contains(genreId), true);
      
      // Act & Assert - Second toggle removes
      await userStore.toggleSelectedGenre(genreId);
      expect(userStore.selectedGenreIds.contains(genreId), false);
    });
  });
} 