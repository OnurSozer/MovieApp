import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/movie.dart';
import '../../stores/movie_store.dart';
import '../../stores/user_store.dart';
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
  final PageController _pageController = PageController(
    viewportFraction: 0.5,
    initialPage: 0,
  );
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
    
    // Otherwise toggle as normal
    _userStore.toggleFavoriteMovie(movie);
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
            
            // Curved carousel of movies
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
                        child: _buildCurvedCarousel(movies),
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
  
  // Custom curved carousel widget
  Widget _buildCurvedCarousel(List<Movie> movies) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      itemCount: movies.length + (_isLoadingMore ? 1 : 0),
      onPageChanged: (index) {
        if (index >= movies.length - 5 && !_isLoadingMore && !_movieStore.isLoading) {
          _loadMoreMovies();
        }
      },
      itemBuilder: (context, index) {
        // If we're at the end and loading more, show a loading indicator
        if (index == movies.length && _isLoadingMore) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                color: AppColors.redLight,
              ),
            ),
          );
        }
        
        // Get movie at current index
        final movie = movies[index];
        
        // Build carousel item with curved effect
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double value = 1.0;
            
            // Calculate the visible percentage of each item
            if (_pageController.position.haveDimensions) {
              value = _pageController.page! - index;
              
              // Scale value between 0.8 and 1
              value = (1 - (value.abs() * 0.3)).clamp(0.8, 1.0);
              
              // Apply curve for cylinder effect
              // Items will get smaller and appear to curve away
              double heightFactor = math.sin(value * math.pi / 2);
              value = heightFactor;
            }
            
            return Center(
              child: SizedBox(
                height: Curves.easeOut.transform(value) * 400,
                width: Curves.easeOut.transform(value) * 220,
                child: child,
              ),
            );
          },
          child: Observer(
            builder: (_) {
              final isSelected = _userStore.favoriteMovieIds.contains(movie.id);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: MovieCard(
                  movie: movie,
                  isSelected: isSelected,
                  onTap: (_) => _toggleMovieSelection(movie),
                  showTitle: false,
                ),
              );
            },
          ),
        );
      },
    );
  }
} 