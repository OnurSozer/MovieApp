import 'package:mocktail/mocktail.dart';
import 'package:movie_app/Model/datasources/movie_api_client.dart';
import 'package:dio/dio.dart';

class MockMovieApiClient extends Mock implements MovieApiClient {}

// Mock response classes
class MockResponseData {
  static Response popularMoviesResponse() {
    return Response(
      data: {
        'page': 1,
        'results': [
          {
            'id': 1,
            'title': 'Test Movie 1',
            'poster_path': '/testpath1.jpg',
            'backdrop_path': '/backdroppath1.jpg',
            'overview': 'This is a test movie description',
            'vote_average': 8.5,
            'genre_ids': [28, 12],
            'release_date': '2023-01-15',
          },
          {
            'id': 2,
            'title': 'Test Movie 2',
            'poster_path': '/testpath2.jpg',
            'backdrop_path': '/backdroppath2.jpg',
            'overview': 'Another test movie description',
            'vote_average': 7.9,
            'genre_ids': [16, 10751],
            'release_date': '2023-02-20',
          },
        ],
        'total_pages': 5,
        'total_results': 100,
      },
      statusCode: 200,
      requestOptions: RequestOptions(path: '/movie/popular'),
    );
  }

  static Response genresResponse() {
    return Response(
      data: {
        'genres': [
          {'id': 28, 'name': 'Action'},
          {'id': 12, 'name': 'Adventure'},
          {'id': 16, 'name': 'Animation'},
          {'id': 10751, 'name': 'Family'},
        ],
      },
      statusCode: 200,
      requestOptions: RequestOptions(path: '/genre/movie/list'),
    );
  }

  static Response moviesByGenreResponse(int genreId) {
    return Response(
      data: {
        'page': 1,
        'results': [
          {
            'id': 3,
            'title': 'Genre Movie 1',
            'poster_path': '/genrepath1.jpg',
            'backdrop_path': '/genrebackdrop1.jpg',
            'overview': 'This is a genre movie',
            'vote_average': 7.8,
            'genre_ids': [genreId],
            'release_date': '2023-03-10',
          },
          {
            'id': 4,
            'title': 'Genre Movie 2',
            'poster_path': '/genrepath2.jpg',
            'backdrop_path': '/genrebackdrop2.jpg',
            'overview': 'Another genre movie',
            'vote_average': 8.1,
            'genre_ids': [genreId],
            'release_date': '2023-03-15',
          },
        ],
        'total_pages': 3,
        'total_results': 50,
      },
      statusCode: 200,
      requestOptions: RequestOptions(path: '/discover/movie'),
    );
  }
} 