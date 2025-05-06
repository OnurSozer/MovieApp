import 'package:mobx/mobx.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Model/entities/movie.dart';
import '../../Model/repositories/movie_repository.dart';

part 'movie_store.g.dart';

class MovieStore = _MovieStore with _$MovieStore;

abstract class _MovieStore with Store {
  final MovieRepository _movieRepository;
  
  _MovieStore(this._movieRepository);
  
  @observable
  ObservableList<Movie> popularMovies = ObservableList<Movie>();
  
  @observable
  ObservableList<MovieGenre> genres = ObservableList<MovieGenre>();
  
  @observable
  ObservableList<Movie> moviesByGenre = ObservableList<Movie>();
  
  @observable
  ObservableList<Movie> favoriteMovies = ObservableList<Movie>();
  
  @observable
  bool isLoading = false;
  
  @observable
  String? errorMessage;
  
  @observable
  int? currentGenreId;
  
  // For dynamic image preloading
  @observable
  ObservableSet<String> preloadedImageUrls = ObservableSet<String>();
  
  @observable
  bool isPreloadingImages = false;
  
  @observable
  int currentPreloadPage = 1;
  
  @action
  Future<void> fetchPopularMovies({int page = 1}) async {
    isLoading = true;
    errorMessage = null;
    
    try {
      final movies = await _movieRepository.getPopularMovies(page: page);
      if (page == 1) {
        popularMovies.clear();
      }
      popularMovies.addAll(movies);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }
  
  @action
  Future<void> fetchAdditionalMovies({required int page}) async {
    try {
      final movies = await _movieRepository.getPopularMovies(page: page);
      popularMovies.addAll(movies);
    } catch (e) {
      // Silently fail for additional pages
      print('Error fetching additional movies: $e');
    }
  }
  
  @action
  Future<void> fetchGenres() async {
    isLoading = true;
    errorMessage = null;
    
    try {
      final fetchedGenres = await _movieRepository.getMovieGenres();
      genres.clear();
      genres.addAll(fetchedGenres);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }
  
  @action
  Future<void> fetchMoviesByGenre(int genreId) async {
    isLoading = true;
    errorMessage = null;
    currentGenreId = genreId;
    
    try {
      final movies = await _movieRepository.getMoviesByGenre(genreId);
      moviesByGenre.clear();
      moviesByGenre.addAll(movies);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }
  
  @action
  Future<void> searchMovies(String query) async {
    isLoading = true;
    errorMessage = null;
    
    try {
      if (query.isEmpty) {
        await fetchPopularMovies();
      } else {
        final movies = await _movieRepository.searchMovies(query);
        popularMovies.clear();
        popularMovies.addAll(movies);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }
  
  @action
  void initializeCache() {
    // Initialize movie cache for infinite scrolling
    currentPreloadPage = 1;
  }
  
  @action
  Future<void> preloadImages(BuildContext context, List<Movie> movies, {int batchSize = 20}) async {
    if (isPreloadingImages) return; // Prevent multiple simultaneous preloads
    
    isPreloadingImages = true;
    
    try {
      // Filter out movies with no poster or already preloaded images
      final moviesToPreload = movies.where((movie) {
        return movie.hasPoster && !preloadedImageUrls.contains(movie.fullPosterPath);
      }).take(batchSize).toList();
      
      if (moviesToPreload.isEmpty) {
        isPreloadingImages = false;
        return;
      }
      
      // Preload in batches of 5 for better performance
      const int parallelBatchSize = 5;
      for (int i = 0; i < moviesToPreload.length; i += parallelBatchSize) {
        final endIndex = (i + parallelBatchSize < moviesToPreload.length) 
            ? i + parallelBatchSize 
            : moviesToPreload.length;
        final batch = moviesToPreload.sublist(i, endIndex);
        
        // Preload this batch in parallel
        await Future.wait(
          batch.map((movie) async {
            try {
              await precacheImage(
                CachedNetworkImageProvider(movie.fullPosterPath),
                context,
              );
              preloadedImageUrls.add(movie.fullPosterPath);
            } catch (e) {
              print('Failed to preload image: ${movie.fullPosterPath}, error: $e');
              // Continue even if individual image preloading fails
            }
          }),
        );
      }
    } finally {
      isPreloadingImages = false;
    }
  }
  
  @action
  Future<void> preloadNextBatchOnScroll(BuildContext context, ScrollController scrollController) async {
    // Check if we need to preload more images
    if (scrollController.position.pixels > 
        scrollController.position.maxScrollExtent * 0.7 &&
        !isPreloadingImages) {
      
      // First, try to preload any remaining visible movies that aren't preloaded
      await preloadImages(context, popularMovies);
      
      // If we need more data, load the next page
      if (!isLoading && popularMovies.length < (currentPreloadPage + 1) * 20) {
        currentPreloadPage++;
        await fetchAdditionalMovies(page: currentPreloadPage);
      }
    }
  }
  
  @action
  void addToFavorites(Movie movie) {
    if (!favoriteMovies.any((m) => m.id == movie.id)) {
      favoriteMovies.add(movie);
      _savePreferences();
    }
  }
  
  @action
  void removeFromFavorites(Movie movie) {
    favoriteMovies.removeWhere((m) => m.id == movie.id);
    _savePreferences();
  }
  
  @action
  Future<void> loadFavorites() async {
    try {
      final favorites = await _movieRepository.getFavoriteMovies();
      favoriteMovies.clear();
      favoriteMovies.addAll(favorites);
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }
  
  Future<void> _savePreferences() async {
    try {
      await _movieRepository.saveFavoriteMovies(favoriteMovies.toList());
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }
} 