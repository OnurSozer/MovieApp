import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/Model/repositories/movie_repository_impl.dart';
import 'package:movie_app/Model/entities/movie.dart';
import 'package:dio/dio.dart';
import '../mocks/mock_api_client.dart';

class FakeResponse extends Fake implements Response {}

void main() {
  late MockMovieApiClient mockApiClient;
  late MovieRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(FakeResponse());
  });

  setUp(() {
    mockApiClient = MockMovieApiClient();
    repository = MovieRepositoryImpl(mockApiClient);
  });

  group('MovieRepositoryImpl Tests', () {
    test('getPopularMovies should return list of movies on success', () async {
      // Arrange
      final response = MockResponseData.popularMoviesResponse();
      when(() => mockApiClient.getPopularMovies(page: any(named: 'page')))
          .thenAnswer((_) async => response);
      
      // Act
      final result = await repository.getPopularMovies();
      
      // Assert
      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[0].title, 'Test Movie 1');
      expect(result[1].id, 2);
      expect(result[1].title, 'Test Movie 2');
      verify(() => mockApiClient.getPopularMovies(page: any(named: 'page'))).called(1);
    });

    test('getPopularMovies should handle API error correctly', () async {
      // Arrange
      when(() => mockApiClient.getPopularMovies(page: any(named: 'page')))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: '/movie/popular'),
            type: DioExceptionType.connectionTimeout,
          ));
      
      // Act & Assert
      expect(
        () => repository.getPopularMovies(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Connection timeout'),
        )),
      );
      verify(() => mockApiClient.getPopularMovies(page: any(named: 'page'))).called(1);
    });

    test('getMovieGenres should return list of genres on success', () async {
      // Arrange
      final response = MockResponseData.genresResponse();
      when(() => mockApiClient.getMovieGenres())
          .thenAnswer((_) async => response);
      
      // Act
      final result = await repository.getMovieGenres();
      
      // Assert
      expect(result.length, 4);
      expect(result[0].id, 28);
      expect(result[0].name, 'Action');
      expect(result[1].id, 12);
      expect(result[1].name, 'Adventure');
      verify(() => mockApiClient.getMovieGenres()).called(1);
    });

    test('getMoviesByGenre should return list of movies for the genre', () async {
      // Arrange
      const genreId = 28;
      final response = MockResponseData.moviesByGenreResponse(genreId);
      when(() => mockApiClient.getMoviesByGenre(any()))
          .thenAnswer((_) async => response);
      
      // Act
      final result = await repository.getMoviesByGenre(genreId);
      
      // Assert
      expect(result.length, 2);
      expect(result[0].id, 3);
      expect(result[0].title, 'Genre Movie 1');
      expect(result[1].id, 4);
      expect(result[1].title, 'Genre Movie 2');
      expect(result[0].genreIds, contains(genreId));
      verify(() => mockApiClient.getMoviesByGenre(any())).called(1);
    });

    test('searchMovies should return matching movies', () async {
      // Arrange
      const query = 'Test';
      final response = MockResponseData.popularMoviesResponse();
      when(() => mockApiClient.searchMovies(any()))
          .thenAnswer((_) async => response);
      
      // Act
      final result = await repository.searchMovies(query);
      
      // Assert
      expect(result.length, 2);
      expect(result[0].title, contains('Test'));
      expect(result[1].title, contains('Test'));
      verify(() => mockApiClient.searchMovies(any())).called(1);
    });
  });
} 