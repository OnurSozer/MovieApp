import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/Model/entities/movie.dart';
import 'package:movie_app/ViewModel/stores/movie_store.dart';
import '../mocks/mock_movie_repository.dart';

class FakeList<T> extends Fake implements List<T> {}

void main() {
  late MockMovieRepository mockRepository;
  late MovieStore movieStore;

  setUpAll(() {
    registerFallbackValue(FakeList<Movie>());
  });

  setUp(() {
    mockRepository = MockMovieRepository();
    movieStore = MovieStore(mockRepository);
  });

  group('MovieStore Tests', () {
    test('fetchPopularMovies should update popularMovies list on success', () async {
      // Arrange
      final testMovies = TestMovieData.getPopularMovies();
      when(() => mockRepository.getPopularMovies(page: any(named: 'page')))
          .thenAnswer((_) async => testMovies);
      
      // Act
      await movieStore.fetchPopularMovies();
      
      // Assert
      expect(movieStore.isLoading, false);
      expect(movieStore.errorMessage, null);
      expect(movieStore.popularMovies.length, 2);
      expect(movieStore.popularMovies[0].id, 1);
      expect(movieStore.popularMovies[1].id, 2);
      verify(() => mockRepository.getPopularMovies(page: any(named: 'page'))).called(1);
    });

    test('fetchPopularMovies should set errorMessage on failure', () async {
      // Arrange
      when(() => mockRepository.getPopularMovies(page: any(named: 'page')))
          .thenThrow(Exception('Network error'));
      
      // Act
      await movieStore.fetchPopularMovies();
      
      // Assert
      expect(movieStore.isLoading, false);
      expect(movieStore.errorMessage, isNotNull);
      expect(movieStore.errorMessage, contains('Network error'));
      expect(movieStore.popularMovies, isEmpty);
      verify(() => mockRepository.getPopularMovies(page: any(named: 'page'))).called(1);
    });

    test('fetchGenres should update genres list on success', () async {
      // Arrange
      final testGenres = TestMovieData.getGenres();
      when(() => mockRepository.getMovieGenres())
          .thenAnswer((_) async => testGenres);
      
      // Act
      await movieStore.fetchGenres();
      
      // Assert
      expect(movieStore.isLoading, false);
      expect(movieStore.errorMessage, null);
      expect(movieStore.genres.length, 4);
      expect(movieStore.genres[0].id, 28);
      expect(movieStore.genres[1].name, 'Adventure');
      verify(() => mockRepository.getMovieGenres()).called(1);
    });

    test('fetchMoviesByGenre should update moviesByGenre list on success', () async {
      // Arrange
      final testMovies = TestMovieData.getPopularMovies();
      const genreId = 28;
      when(() => mockRepository.getMoviesByGenre(any()))
          .thenAnswer((_) async => testMovies);
      
      // Act
      await movieStore.fetchMoviesByGenre(genreId);
      
      // Assert
      expect(movieStore.isLoading, false);
      expect(movieStore.errorMessage, null);
      expect(movieStore.currentGenreId, genreId);
      expect(movieStore.moviesByGenre.length, 2);
      verify(() => mockRepository.getMoviesByGenre(any())).called(1);
    });

    test('searchMovies should update popularMovies list when query is not empty', () async {
      // Arrange
      final testMovies = TestMovieData.getPopularMovies().take(1).toList();
      const query = 'Test Movie 1';
      when(() => mockRepository.searchMovies(any()))
          .thenAnswer((_) async => testMovies);
      
      // Act
      await movieStore.searchMovies(query);
      
      // Assert
      expect(movieStore.isLoading, false);
      expect(movieStore.errorMessage, null);
      expect(movieStore.popularMovies.length, 1);
      expect(movieStore.popularMovies[0].title, 'Test Movie 1');
      verify(() => mockRepository.searchMovies(any())).called(1);
    });

    test('searchMovies should call fetchPopularMovies when query is empty', () async {
      // Arrange
      final testMovies = TestMovieData.getPopularMovies();
      when(() => mockRepository.getPopularMovies(page: any(named: 'page')))
          .thenAnswer((_) async => testMovies);
      
      // Act
      await movieStore.searchMovies('');
      
      // Assert
      expect(movieStore.isLoading, false);
      expect(movieStore.errorMessage, null);
      expect(movieStore.popularMovies.length, 2);
      verify(() => mockRepository.getPopularMovies(page: any(named: 'page'))).called(1);
      verifyNever(() => mockRepository.searchMovies(any()));
    });

    test('addToFavorites should add movie to favorites list', () async {
      // Arrange
      final testMovie = TestMovieData.getPopularMovies()[0];
      when(() => mockRepository.saveFavoriteMovies(any()))
          .thenAnswer((_) async {});
      
      // Act
      movieStore.addToFavorites(testMovie);
      
      // Assert
      expect(movieStore.favoriteMovies.length, 1);
      expect(movieStore.favoriteMovies[0].id, testMovie.id);
      verify(() => mockRepository.saveFavoriteMovies(any())).called(1);
    });

    test('removeFromFavorites should remove movie from favorites list', () async {
      // Arrange
      final testMovie = TestMovieData.getPopularMovies()[0];
      when(() => mockRepository.saveFavoriteMovies(any()))
          .thenAnswer((_) async {});
      movieStore.addToFavorites(testMovie);
      
      // Act
      movieStore.removeFromFavorites(testMovie);
      
      // Assert
      expect(movieStore.favoriteMovies, isEmpty);
      verify(() => mockRepository.saveFavoriteMovies(any())).called(2);
    });

    test('loadFavorites should update favoriteMovies list on success', () async {
      // Arrange
      final testMovies = TestMovieData.getPopularMovies();
      when(() => mockRepository.getFavoriteMovies())
          .thenAnswer((_) async => testMovies);
      
      // Act
      await movieStore.loadFavorites();
      
      // Assert
      expect(movieStore.favoriteMovies.length, 2);
      expect(movieStore.favoriteMovies[0].id, 1);
      expect(movieStore.favoriteMovies[1].id, 2);
      verify(() => mockRepository.getFavoriteMovies()).called(1);
    });
  });
} 