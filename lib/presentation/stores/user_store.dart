import 'package:mobx/mobx.dart';
import '../../data/datasources/user_preferences.dart';
import '../../domain/entities/movie.dart';

part 'user_store.g.dart';

class UserStore = _UserStore with _$UserStore;

abstract class _UserStore with Store {
  final UserPreferences _userPreferences;
  
  _UserStore(this._userPreferences);
  
  @observable
  ObservableList<int> favoriteMovieIds = ObservableList<int>();
  
  @observable
  ObservableList<int> selectedGenreIds = ObservableList<int>();
  
  @observable
  bool isOnboardingCompleted = false;
  
  @observable
  String subscriptionStatus = 'free'; // 'free', 'premium'
  
  @action
  Future<void> initPreferences() async {
    try {
      // Load onboarding status
      isOnboardingCompleted = await _userPreferences.isOnboardingCompleted();
      
      // Load favorite movie IDs
      final savedFavoriteMovieIds = await _userPreferences.getFavoriteMovieIds();
      favoriteMovieIds.clear();
      favoriteMovieIds.addAll(savedFavoriteMovieIds);
      
      // Load selected genre IDs
      final savedGenreIds = await _userPreferences.getSelectedGenreIds();
      selectedGenreIds.clear();
      selectedGenreIds.addAll(savedGenreIds);
      
      // Load subscription status
      subscriptionStatus = await _userPreferences.getSubscriptionStatus();
      
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }
  
  @action
  Future<void> addFavoriteMovie(Movie movie) async {
    if (!favoriteMovieIds.contains(movie.id)) {
      favoriteMovieIds.add(movie.id);
      await _saveFavoriteMovieIds();
    }
  }
  
  @action
  Future<void> removeFavoriteMovie(int movieId) async {
    favoriteMovieIds.remove(movieId);
    await _saveFavoriteMovieIds();
  }
  
  @action
  Future<void> toggleFavoriteMovie(Movie movie) async {
    if (favoriteMovieIds.contains(movie.id)) {
      await removeFavoriteMovie(movie.id);
    } else {
      await addFavoriteMovie(movie);
    }
  }
  
  @action
  Future<void> addSelectedGenre(int genreId) async {
    if (!selectedGenreIds.contains(genreId)) {
      selectedGenreIds.add(genreId);
      await _saveSelectedGenreIds();
    }
  }
  
  @action
  Future<void> removeSelectedGenre(int genreId) async {
    selectedGenreIds.remove(genreId);
    await _saveSelectedGenreIds();
  }
  
  @action
  Future<void> toggleSelectedGenre(int genreId) async {
    if (selectedGenreIds.contains(genreId)) {
      await removeSelectedGenre(genreId);
    } else {
      await addSelectedGenre(genreId);
    }
  }
  
  @action
  Future<void> completeOnboarding() async {
    isOnboardingCompleted = true;
    await _userPreferences.setCompletedOnboarding(true);
  }
  
  @action
  Future<void> updateSubscription(String status) async {
    subscriptionStatus = status;
    await _userPreferences.setSubscriptionStatus(status);
  }
  
  Future<void> _saveFavoriteMovieIds() async {
    // This is a simplified version - in reality, you would need to save the full movie objects
    final movies = favoriteMovieIds.map((id) => 
      Movie(
        id: id,
        title: 'Placeholder',
        overview: 'Placeholder',
        voteAverage: 0,
        genreIds: [],
        releaseDate: '',
      )
    ).toList();
    
    await _userPreferences.saveFavoriteMovies(movies);
  }
  
  Future<void> _saveSelectedGenreIds() async {
    // This is a simplified version - in reality, you would need to save the full genre objects
    final genres = selectedGenreIds.map((id) => 
      MovieGenre(id: id, name: 'Placeholder')
    ).toList();
    
    await _userPreferences.saveSelectedGenres(genres);
  }
} 