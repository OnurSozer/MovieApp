import 'package:mocktail/mocktail.dart';
import 'package:movie_app/Model/entities/movie.dart';
import 'package:movie_app/Model/repositories/movie_repository.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

// Sample test data
class TestMovieData {
  static List<Movie> getPopularMovies() {
    return [
      Movie(
        id: 1,
        title: 'Test Movie 1',
        posterPath: '/testpath1.jpg',
        backdropPath: '/backdroppath1.jpg',
        overview: 'This is a test movie description',
        voteAverage: 8.5,
        genreIds: [28, 12],
        releaseDate: '2023-01-15',
      ),
      Movie(
        id: 2,
        title: 'Test Movie 2',
        posterPath: '/testpath2.jpg',
        backdropPath: '/backdroppath2.jpg',
        overview: 'Another test movie description',
        voteAverage: 7.9,
        genreIds: [16, 10751],
        releaseDate: '2023-02-20',
      ),
    ];
  }

  static List<MovieGenre> getGenres() {
    return [
      MovieGenre(id: 28, name: 'Action'),
      MovieGenre(id: 12, name: 'Adventure'),
      MovieGenre(id: 16, name: 'Animation'),
      MovieGenre(id: 10751, name: 'Family'),
    ];
  }
} 