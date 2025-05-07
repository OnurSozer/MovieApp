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
import 'package:cached_network_image/cached_network_image.dart';

class MovieSelectionScreen extends StatefulWidget {
  const MovieSelectionScreen({Key? key}) : super(key: key);

  @override
  _MovieSelectionScreenState createState() => _MovieSelectionScreenState();
}

class _MovieSelectionScreenState extends State<MovieSelectionScreen> {
  late MovieStore _movieStore;
  late UserStore _userStore;
  bool _isLoadingMore = false;
  
  // Required number of favorite movies
  static const int requiredSelections = 3;
  
  @override
  void initState() {
    super.initState();
    
    // Get stores from dependency injection
    _movieStore = GetIt.instance<MovieStore>();
    _userStore = GetIt.instance<UserStore>();
    
    // Fetch popular movies if needed (may already be loaded from splash screen)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_movieStore.popularMovies.isEmpty) {
        _fetchInitialMovies();
      }
    });
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchInitialMovies() async {
    await _movieStore.fetchPopularMovies(page: 1);
  }
  
  Future<void> _loadMoreMovies() async {
    if (_isLoadingMore || _movieStore.isLoading) return;
    
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
                    return const SizedBox(height: 23); // Same height as the text would take
                  }
                  
                  return Text(
                    'Choose your ${requiredSelections} favorite movies',
                    style: AppTextStyles.bodyLarge,
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Horizontally scrollable movie pairs
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
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: HorizontalMovieScroller(
                          movies: movies,
                          onToggleSelection: _toggleMovieSelection,
                          userStore: _userStore,
                          onLoadMore: _loadMoreMovies,
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

// HorizontalMovieScroller is an object-oriented class that handles displaying horizontally scrollable movies
class HorizontalMovieScroller extends StatefulWidget {
  final List<Movie> movies;
  final Function(Movie) onToggleSelection;
  final UserStore userStore;
  final VoidCallback? onLoadMore;

  const HorizontalMovieScroller({
    Key? key,
    required this.movies,
    required this.onToggleSelection,
    required this.userStore,
    this.onLoadMore,
  }) : super(key: key);

  @override
  _HorizontalMovieScrollerState createState() => _HorizontalMovieScrollerState();
}

class _HorizontalMovieScrollerState extends State<HorizontalMovieScroller> {
  // Create an internal scroll controller that's not shared with parent
  final ScrollController _internalScrollController = ScrollController();
  
  // Track the current scroll position to calculate animations
  double _currentScrollPosition = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Add our own scroll listener for infinite scrolling and animation updates
    _internalScrollController.addListener(_onInternalScroll);
  }
  
  @override
  void dispose() {
    _internalScrollController.removeListener(_onInternalScroll);
    _internalScrollController.dispose();
    super.dispose();
  }
  
  void _onInternalScroll() {
    // Update current scroll position for animations
    setState(() {
      _currentScrollPosition = _internalScrollController.position.pixels;
    });
    
    // Load more movies when reaching the end (infinite scrolling)
    if (_internalScrollController.position.pixels >= 
        _internalScrollController.position.maxScrollExtent * 0.8 &&
        widget.onLoadMore != null) {
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6, // Fixed height container
      child: ListView.builder(
        controller: _internalScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.movies.length,
        itemBuilder: (context, index) {
          return _buildAnimatedMovieCard(context, widget.movies[index], index);
        },
      ),
    );
  }

  Widget _buildAnimatedMovieCard(BuildContext context, Movie movie, int index) {
    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Define the width of each movie card container
    final containerWidth = screenWidth * 0.5;
    
    // Define base card height
    final baseCardHeight = screenHeight * 0.35;
    
    // Define the spacing between cards
    final cardSpacing = 0.0;
    
    // Calculate the center position of this item
    final itemCenter = index * (containerWidth + cardSpacing) + (containerWidth / 2);
    
    // Calculate how far this item is from the center of the screen
    final scrollCenter = _currentScrollPosition + (screenWidth / 2);
    
    // Calculate normalized horizontal position (-1 to 1, where 0 is center)
    final normalizedPosition = ((itemCenter - scrollCenter) / (screenWidth * 0.5)).clamp(-1.0, 1.0);
    
    // Calculate unified curve parameters
    final curveProgress = normalizedPosition.abs();
    
    // Calculate z-depth - center back, edges forward
    final maxZOffset = 100.0;
    final zOffset = maxZOffset * (1 - curveProgress);
    
    // Calculate vertical offset for unified curve
    final maxVerticalOffset = 50.0;
    final verticalOffset = -maxVerticalOffset * curveProgress + 50;
    
    // Calculate scale factor - smaller in center, larger at edges
    final minScale = 0.9;
    final scaleFactor = minScale + ((1.0 - minScale) * curveProgress);
    
    // Calculate rotation to follow the curve
    final rotationAngle = normalizedPosition * 0.7;
    
    // Calculate height factor - consistent with curve
    
    // Apply transform for unified curve effect
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective
      ..translate(0.0, verticalOffset, zOffset)
      ..scale(scaleFactor)
      ..rotateY(rotationAngle);
    
    return Observer(
      builder: (_) {
        final isSelected = widget.userStore.favoriteMovieIds.contains(movie.id);
        
        return Transform(
          transform: transform,
          alignment: Alignment.topCenter,
          child: Container(
            width: containerWidth,
            padding: EdgeInsets.symmetric(horizontal: cardSpacing / 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(vertical: 130.0),
              decoration: BoxDecoration(
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  // Enhanced shadow for depth
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1 + (0.2 * curveProgress)),
                    blurRadius: 15,
                    offset: Offset(normalizedPosition * 8, 5),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: MovieCard(
                movie: movie,
                isSelected: isSelected,
                onTap: widget.onToggleSelection,
                showTitle: false,
              ),
            ),
          ),
        );
      },
    );
  }
} 