import 'package:mobx/mobx.dart';
import '../../Model/entities/movie.dart';
import 'movie_store.dart';
import 'user_store.dart';

// A simple MobX store implementation
class RecommendationStore {
  final MovieStore movieStore;
  final UserStore userStore;

  // Create the observable properties
  final _isLoading = Observable<bool>(false);
  final _recommendations = ObservableList<Movie>();

  // Constructor
  RecommendationStore({
    required this.movieStore,
    required this.userStore,
  });
  
  // Getters for the observable properties
  bool get isLoading => _isLoading.value;
  List<Movie> get recommendations => _recommendations;
  bool get hasRecommendations => _recommendations.isNotEmpty;

  // Recommendation generator
  Future<void> generateRecommendations() async {
    // Use runInAction to modify observables
    runInAction(() {
      _isLoading.value = true;
    });
    
    try {
      // Add a small delay to show loading indicator
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Calculate recommendations (doesn't modify any observables)
      final newRecommendations = _calculateRecommendations();

      // Use runInAction again to modify observables
      runInAction(() {
        _recommendations.clear();
        _recommendations.addAll(newRecommendations);
      });
    } finally {
      // Always set loading to false when done
      runInAction(() {
        _isLoading.value = false;
      });
    }
  }

  // Pure calculation function (doesn't modify any observables)
  List<Movie> _calculateRecommendations() {
    final allMovies = movieStore.popularMovies;
    if (allMovies.isEmpty) return [];

    // Create a map to score movies based on user preferences
    final Map<int, double> movieScores = {};
    final Set<int> favoriteMovieIds = userStore.favoriteMovieIds.toSet();
    final Set<int> favoriteGenreIds = userStore.selectedGenreIds.toSet();

    // Score algorithm - higher score = more relevant to user
    for (final movie in allMovies) {
      // Skip movies that are already in user's favorites
      if (favoriteMovieIds.contains(movie.id)) continue;

      double score = 0;

      // 1. Genre match with user's favorite genres (higher weight)
      for (final genreId in movie.genreIds) {
        if (favoriteGenreIds.contains(genreId)) {
          score += 2.0; // Each matching genre adds points
        }
      }

      // 2. Similarity to favorite movies - we need to find them using the IDs
      final userFavoriteMovies = allMovies.where(
        (m) => favoriteMovieIds.contains(m.id)
      ).toList();
      
      for (final favoriteMovie in userFavoriteMovies) {
        // Common genres between this movie and favorite movie
        final commonGenres = movie.genreIds
            .where((genre) => favoriteMovie.genreIds.contains(genre))
            .length;
        
        if (commonGenres > 0) {
          score += commonGenres * 0.5; // Each common genre with a favorite movie adds points
        }
      }

      // 3. Boost recent/popular content a bit
      score += 0.2; // Basic score for being in popular list

      // Store final score
      movieScores[movie.id] = score;
    }

    // Sort movies by score and take top results
    final sortedMovies = allMovies
        .where((movie) => movieScores.containsKey(movie.id))
        .toList()
      ..sort((a, b) => 
          (movieScores[b.id] ?? 0).compareTo(movieScores[a.id] ?? 0));

    // Return top recommendations (limited to 10)
    return sortedMovies.take(10).toList();
  }
} 