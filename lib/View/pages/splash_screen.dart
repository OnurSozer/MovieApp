import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../ViewModel/stores/user_store.dart';
import '../../ViewModel/stores/movie_store.dart';
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
  
  // Constants for pagination
  static const int _initialMoviePages = 3;
  static const int _initialGenresToPreload = 5;
  static const int _initialImagesToPreload = 30;

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
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
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
      // Load user preferences
      await _userStore.initPreferences();
      
      // Load multiple pages of popular movies for infinite scroll
      await _movieStore.fetchPopularMovies(page: 1);
      
      // Load additional pages for pagination
      for (int page = 2; page <= _initialMoviePages; page++) {
        await _movieStore.fetchAdditionalMovies(page: page);
      }
      
      // Load genres
      await _movieStore.fetchGenres();
      
      // Preload genre-specific movies
      if (_userStore.selectedGenreIds.isNotEmpty) {
        final genresToPreload = _userStore.selectedGenreIds.take(_initialGenresToPreload).toList();
        for (final genreId in genresToPreload) {
          await _movieStore.fetchMoviesByGenre(genreId);
        }
      } else if (_movieStore.genres.isNotEmpty) {
        final genresToPreload = _movieStore.genres.take(_initialGenresToPreload).toList();
        for (final genre in genresToPreload) {
          await _movieStore.fetchMoviesByGenre(genre.id);
        }
      }
      
      // Preload initial batch of images
      await _preloadInitialImages();
      
      // Initialize movie cache for infinite scroll
      _movieStore.initializeCache();
      
      // Additional delay to ensure all animations complete
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Navigate to the appropriate screen
      if (mounted) {
        final route = _userStore.isOnboardingCompleted
            ? MaterialPageRoute(builder: (_) => const MainScreen())
            : MaterialPageRoute(builder: (_) => const MovieSelectionScreen());
        
        Navigator.pushReplacement(context, route);
      }
    } catch (e) {
      print('Error during preloading: $e');
      // Silently handle error and still try to navigate
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MovieSelectionScreen()),
        );
      }
    }
  }
  
  Future<void> _preloadInitialImages() async {
    final allMovies = [
      ..._movieStore.popularMovies,
      ..._movieStore.moviesByGenre,
    ].toSet().toList();
    
    allMovies.sort((a, b) {
      final aMatchesUserGenres = a.genreIds.any((id) => _userStore.selectedGenreIds.contains(id));
      final bMatchesUserGenres = b.genreIds.any((id) => _userStore.selectedGenreIds.contains(id));
      
      if (aMatchesUserGenres && !bMatchesUserGenres) return -1;
      if (!aMatchesUserGenres && bMatchesUserGenres) return 1;
      
      return b.voteAverage.compareTo(a.voteAverage);
    });
    
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
                    Image.asset(
                      'assets/icons/appIcon5.png',
                      width: 250,
                      height: 250,
                    ),
                    Text(
                      'MovieHub',
                      style: AppTextStyles.heading1,
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