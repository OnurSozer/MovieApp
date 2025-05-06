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
                      Expanded(
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
    return ListView.builder(
      controller: _internalScrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.movies.length,
      itemBuilder: (context, index) {
        final movie = widget.movies[index];
        return _buildAnimatedMovieCard(context, movie, index);
      },
    );
  }

  Widget _buildAnimatedMovieCard(BuildContext context, Movie movie, int index) {
    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Define the width of each movie card container
    // We'll make them take about 75% of screen width for better focus
    final containerWidth = screenWidth * 0.55;
    
    // Define card height - adjust this value to make cards taller or shorter
    final cardHeight = screenHeight * 0.35; // 35% of screen height
    
    // Define the spacing between cards
    // Increase or decrease this value to change the distance between cards
    final cardSpacing = 1.0;
    
    // Calculate the center position of this item
    // Add cardSpacing to create distance between each card
    final itemCenter = index * (containerWidth + cardSpacing) + (containerWidth / 2);
    
    // Calculate how far this item is from the center of the screen
    final scrollCenter = _currentScrollPosition + (screenWidth / 2);
    final distanceFromCenter = (itemCenter - scrollCenter).abs();
    
    // Calculate scale factor based on distance from center
    // Items at the center have scale of 1.0, items far away have scale of 0.85
    final scaleFactor = 1.0 - (distanceFromCenter / screenWidth).clamp(0.0, 0.15);
    
    // Calculate rotation based on distance from center
    // Items to the left rotate slightly right, items to the right rotate slightly left
    final direction = itemCenter > scrollCenter ? -1.0 : 1.0;
    final rotationAngle = direction * (distanceFromCenter / screenWidth).clamp(0.0, 0.05);
    
    // Apply 3D-like transform using Matrix4
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective
      ..scale(scaleFactor)
      ..rotateY(rotationAngle);
    
    // Use Observer here to make sure the widget rebuilds when favoriteMovieIds changes
    return Observer(
      builder: (_) {
        final isSelected = widget.userStore.favoriteMovieIds.contains(movie.id);
        
        // Add a slightly brighter shadow for the focused items
        final glowOpacity = (scaleFactor - 0.85) * 6.67; // Map 0.85-1.0 scale to 0.0-1.0 opacity
        
        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: Container(
            width: containerWidth,
            // This padding controls the horizontal spacing between cards
            // Increase the horizontal padding to create more space between cards
            padding: EdgeInsets.symmetric(horizontal: cardSpacing / 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(vertical: 100.0),
              decoration: BoxDecoration(
                boxShadow: [
                  // Selection shadow (if selected)
                  if (isSelected)
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  // Focus glow effect based on scale factor
                  BoxShadow(
                    color: Colors.white.withOpacity(glowOpacity * 0.3),
                    blurRadius: 15,
                    spreadRadius: -2,
                  ),
                ],
              ),
              height: cardHeight, // Using our defined cardHeight
              child: ClipRRect(
                // Create a custom implementation instead of using MovieCard
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Movie poster image
                    movie.hasPoster 
                        ? CachedNetworkImage(
                            imageUrl: movie.fullPosterPath,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.greyDark,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.redLight,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.greyDark,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.movie_outlined,
                                      color: AppColors.white.withOpacity(0.7),
                                      size: 40,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No Image',
                                      style: TextStyle(
                                        color: AppColors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.greyDark,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.movie_outlined,
                                    color: AppColors.white.withOpacity(0.7),
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No Image',
                                    style: TextStyle(
                                      color: AppColors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    
                    // Selection overlay
                    if (isSelected)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: AppColors.redLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check,
                              color: AppColors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    
                    // Make the entire card tappable
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => widget.onToggleSelection(movie),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 