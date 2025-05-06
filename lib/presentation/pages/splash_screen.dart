import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../stores/user_store.dart';
import '../stores/movie_store.dart';
import 'onboarding/movie_selection_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late UserStore _userStore;
  late MovieStore _movieStore;
  String _loadingStatus = "Initializing...";
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = "";
  
  // Constants for pagination
  static const int _initialMoviePages = 3; // Load first 3 pages of movies (60 movies)
  static const int _initialGenresToPreload = 5; // Preload movies for first 5 genres
  static const int _initialImagesToPreload = 30; // Initial preload batch size

  @override
  void initState() {
    super.initState();
    
    // Get stores from dependency injection
    _userStore = GetIt.instance<UserStore>();
    _movieStore = GetIt.instance<MovieStore>();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    
    // Start animation
    _animationController.forward();
    
    // Initialize user preferences and preload data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadDataAndNavigate();
    });
  }

  Future<void> _preloadDataAndNavigate() async {
    try {
      // Step 1: Load user preferences
      setState(() => _loadingStatus = "Loading user preferences...");
      await _userStore.initPreferences();
      
      // Step 2: Load multiple pages of popular movies for infinite scroll
      setState(() => _loadingStatus = "Loading movies (page 1/$_initialMoviePages)...");
      await _movieStore.fetchPopularMovies(page: 1);
      
      // Load additional pages for pagination
      for (int page = 2; page <= _initialMoviePages; page++) {
        setState(() => _loadingStatus = "Loading movies (page $page/$_initialMoviePages)...");
        await _movieStore.fetchAdditionalMovies(page: page);
      }
      
      // Step 3: Load genres
      setState(() => _loadingStatus = "Loading genres...");
      await _movieStore.fetchGenres();
      
      // Step 4: Preload genre-specific movies
      if (_userStore.selectedGenreIds.isNotEmpty) {
        setState(() => _loadingStatus = "Loading recommended movies...");
        // Prioritize user's selected genres
        final genresToPreload = _userStore.selectedGenreIds.take(_initialGenresToPreload).toList();
        for (int i = 0; i < genresToPreload.length; i++) {
          final genreId = genresToPreload[i];
          setState(() => _loadingStatus = "Loading genre movies (${i+1}/${genresToPreload.length})...");
          await _movieStore.fetchMoviesByGenre(genreId);
        }
      } else if (_movieStore.genres.isNotEmpty) {
        // If no user preferences, preload the first few genres
        final genresToPreload = _movieStore.genres.take(_initialGenresToPreload).toList();
        for (int i = 0; i < genresToPreload.length; i++) {
          final genre = genresToPreload[i];
          setState(() => _loadingStatus = "Loading ${genre.name} movies (${i+1}/${genresToPreload.length})...");
          await _movieStore.fetchMoviesByGenre(genre.id);
        }
      }
      
      // Step 5: Preload initial batch of images
      setState(() => _loadingStatus = "Preloading images...");
      await _preloadInitialImages();
      
      // Initialize movie cache for infinite scroll
      setState(() => _loadingStatus = "Initializing cache...");
      _movieStore.initializeCache();
      
      // Additional delay to ensure all animations complete
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() => _isLoading = false);
      
      // Navigate to the appropriate screen
      if (mounted) {
        final route = _userStore.isOnboardingCompleted
            ? MaterialPageRoute(builder: (_) => const MainScreen())
            : MaterialPageRoute(builder: (_) => const MovieSelectionScreen());
        
        Navigator.pushReplacement(context, route);
      }
    } catch (e) {
      print('Error during preloading: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _preloadInitialImages() async {
    // Get all available movies to preload from
    final allMovies = [
      ..._movieStore.popularMovies,
      ..._movieStore.moviesByGenre,
    ].toSet().toList();  // Remove duplicates
    
    // Prioritize movies that will appear on the main screen
    allMovies.sort((a, b) {
      // Prioritize movies from user's selected genres
      final aMatchesUserGenres = a.genreIds.any((id) => _userStore.selectedGenreIds.contains(id));
      final bMatchesUserGenres = b.genreIds.any((id) => _userStore.selectedGenreIds.contains(id));
      
      if (aMatchesUserGenres && !bMatchesUserGenres) return -1;
      if (!aMatchesUserGenres && bMatchesUserGenres) return 1;
      
      // Then prioritize by vote average
      return b.voteAverage.compareTo(a.voteAverage);
    });
    
    // Preload initial batch with the new preloading system
    setState(() => _loadingStatus = "Preloading initial images...");
    await _movieStore.preloadImages(context, allMovies, batchSize: _initialImagesToPreload);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.movie,
                        size: 80,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'MovieHub',
                      style: AppTextStyles.heading1,
                    ),
                    const SizedBox(height: 32),
                    if (_isLoading)
                      Column(
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.redLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _loadingStatus,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    if (_hasError)
                      Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.redLight,
                            size: 40,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading data',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                                _hasError = false;
                                _errorMessage = "";
                              });
                              _preloadDataAndNavigate();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 