import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../Model/entities/movie.dart';
import '../../../ViewModel/stores/movie_store.dart';
import '../../../ViewModel/stores/user_store.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/movie_card.dart';
import 'genre_selection_screen.dart';

class MovieSelectionScreen extends StatefulWidget {
  const MovieSelectionScreen({Key? key}) : super(key: key);

  @override
  _MovieSelectionScreenState createState() => _MovieSelectionScreenState();
}

class _MovieSelectionScreenState extends State<MovieSelectionScreen> {
  late MovieStore _movieStore;
  late UserStore _userStore;
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  bool _isLoadingMore = false;
  
  // Required number of favorite movies
  static const int requiredSelections = 3;
  
  @override
  void initState() {
    super.initState();
    
    // Get stores from dependency injection
    _movieStore = GetIt.instance<MovieStore>();
    _userStore = GetIt.instance<UserStore>();
    
    // Add scroll listener for infinite scrolling
    _scrollController.addListener(_onScroll);
    
    // Fetch popular movies if needed (may already be loaded from splash screen)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_movieStore.popularMovies.isEmpty) {
        _fetchInitialMovies();
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Dynamic image preloading
    _movieStore.preloadNextBatchOnScroll(context, _scrollController);
    
    // Load more movies when reaching the end (infinite scrolling)
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        !_movieStore.isLoading) {
      _loadMoreMovies();
    }
  }

  Future<void> _fetchInitialMovies() async {
    await _movieStore.fetchPopularMovies(page: 1);
  }
  
  Future<void> _loadMoreMovies() async {
    setState(() {
      _isLoadingMore = true;
    });
    
    final nextPage = (_movieStore.popularMovies.length ~/ 20) + 1;
    await _movieStore.fetchAdditionalMovies(page: nextPage);
    
    setState(() {
      _isLoadingMore = false;
    });
  }

  void _toggleMovieSelection(Movie movie) {
    // If user is trying to select more than the required number of movies
    if (_userStore.favoriteMovieIds.length >= requiredSelections && 
        !_userStore.favoriteMovieIds.contains(movie.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can only select $requiredSelections movies'),
          backgroundColor: AppColors.redLight,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Using MobX action to toggle favorite movie
    _userStore.toggleFavoriteMovie(movie);
    
    // Debug print to see selection changes
    print('Movie ${movie.id} selection toggled. Current favorites: ${_userStore.favoriteMovieIds}');
  }

  void _navigateToNextScreen() {
    if (_userStore.favoriteMovieIds.length != requiredSelections) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select exactly $requiredSelections favorite movies'),
          backgroundColor: AppColors.redLight,
        ),
      );
      return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const GenreSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Header changes based on selection status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Observer(
                builder: (_) {
                  final selectedCount = _userStore.favoriteMovieIds.length;
                  final hasRequiredSelections = selectedCount == requiredSelections;
                  
                  if (hasRequiredSelections) {
                    return Row(
                      children: [
                        Text(
                          'Continue to next step',
                          style: AppTextStyles.heading1,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '👉', // Pointing hand emoji instead of arrow icon
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Text(
                      'Welcome',
                      style: AppTextStyles.heading1,
                    );
                  }
                },
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Subtitle text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Observer(
                builder: (_) {
                  final selectedCount = _userStore.favoriteMovieIds.length;
                  final hasRequiredSelections = selectedCount == requiredSelections;
                  
                  // Don't show the subtitle text if 3 movies are selected
                  if (hasRequiredSelections) {
                    return const SizedBox.shrink(); // Empty widget when 3 movies selected
                  }
                  
                  return Text(
                    'Choose your ${requiredSelections} favorite movies',
                    style: AppTextStyles.bodyLarge,
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Movie pair carousel
            Expanded(
              child: Observer(
                builder: (_) {
                  if (_movieStore.isLoading && _movieStore.popularMovies.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.redLight,
                      ),
                    );
                  }
                  
                  if (_movieStore.errorMessage != null && _movieStore.popularMovies.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.redLight,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading movies',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Text(
                              _movieStore.errorMessage!,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _fetchInitialMovies,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  final movies = _movieStore.popularMovies;
                  
                  if (movies.isEmpty) {
                    return const Center(
                      child: Text(
                        'No movies available',
                        style: TextStyle(color: AppColors.white),
                      ),
                    );
                  }
                  
                  return Column(
                    children: [
                      Expanded(
                        child: MoviePairCarousel(
                          movies: movies, 
                          pageController: _pageController,
                          onLoadMore: () {
                            if (!_isLoadingMore && !_movieStore.isLoading) {
                              _loadMoreMovies();
                            }
                          },
                          onToggleSelection: _toggleMovieSelection,
                          userStore: _userStore,
                          isLoadingMore: _isLoadingMore,
                        ),
                      ),
                      
                      // Show loading indicator at bottom for additional feedback
                      if (_isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.redLight,
                                strokeWidth: 2.0,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Continue button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Observer(
                builder: (_) {
                  final hasRequiredSelections = _userStore.favoriteMovieIds.length == requiredSelections;
                  
                  return PrimaryButton(
                    text: 'Continue',
                    onPressed: hasRequiredSelections ? _navigateToNextScreen : null,
                    backgroundColor: AppColors.redLight,
                    disabledBackgroundColor: AppColors.redDark,
                  );
                },
              ),
            ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// MoviePairCarousel is an object-oriented class that handles displaying pairs of movies
class MoviePairCarousel extends StatelessWidget {
  final List<Movie> movies;
  final PageController pageController;
  final VoidCallback onLoadMore;
  final Function(Movie) onToggleSelection;
  final UserStore userStore;
  final bool isLoadingMore;

  const MoviePairCarousel({
    Key? key,
    required this.movies,
    required this.pageController,
    required this.onLoadMore,
    required this.onToggleSelection,
    required this.userStore,
    required this.isLoadingMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate the number of pairs (each page shows a unique pair)
    // We subtract 1 from the length to ensure we always have pairs
    final int pairCount = (movies.length / 2).floor();
    
    return PageView.builder(
      controller: pageController,
      itemCount: pairCount,
      onPageChanged: (index) {
        // Load more when approaching the end
        if (index >= pairCount - 3) {
          onLoadMore();
        }
      },
      itemBuilder: (context, index) {
        // Calculate the correct indices for each pair
        // Each page shows a unique pair (no repeats)
        final leftIndex = index * 2;
        final rightIndex = leftIndex + 1;
        
        // Ensure we don't go out of bounds
        if (rightIndex < movies.length) {
          final leftMovie = movies[leftIndex];
          final rightMovie = movies[rightIndex];
          
          return _buildMoviePair(context, leftMovie, rightMovie);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildMoviePair(BuildContext context, Movie leftMovie, Movie rightMovie) {
    return Row(
      children: [
        // Left movie card
        Expanded(
          child: _buildMovieCard(context, leftMovie, true),
        ),
        
        // Right movie card
        Expanded(
          child: _buildMovieCard(context, rightMovie, false),
        ),
      ],
    );
  }

  Widget _buildMovieCard(BuildContext context, Movie movie, bool isLeftCard) {
    // Use Observer here to make sure the widget rebuilds when favoriteMovieIds changes
    return Observer(
      builder: (_) {
        final isSelected = userStore.favoriteMovieIds.contains(movie.id);
        final screenHeight = MediaQuery.of(context).size.height;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.only(
            left: isLeftCard ? 16.0 : 8.0,
            right: isLeftCard ? 8.0 : 16.0,
            top: 20.0,
            bottom: 20.0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ] : [],
          ),
          height: screenHeight / 3,
          child: MovieCard(
            movie: movie,
            isSelected: isSelected,
            onTap: (_) => onToggleSelection(movie),
            showTitle: false,
          ),
        );
      },
    );
  }
} 