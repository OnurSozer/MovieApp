import '../entities/movie.dart';

abstract class MovieRepository {
  Future<List<Movie>> getPopularMovies({int page = 1});
  Future<List<MovieGenre>> getMovieGenres();
  Future<List<Movie>> getMoviesByGenre(int genreId);
  Future<Movie> getMovieDetails(int movieId);
  Future<List<Movie>> searchMovies(String query);
  Future<List<Movie>> getFavoriteMovies();
  Future<void> saveFavoriteMovies(List<Movie> movies);
} 