import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../Model/entities/movie.dart';
import '../../ViewModel/stores/movie_store.dart';
import '../../ViewModel/stores/user_store.dart';
import '../widgets/genre_chip.dart';
import '../widgets/movie_card.dart';
import '../widgets/personalized_recommendations.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late MovieStore _movieStore;
  late UserStore _userStore;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _genreScrollController = ScrollController();
  int? _selectedGenreForScroll;
  bool _isManuallyScrolling = false;

  @override
  void initState() {
    super.initState();
    
    // Get stores from dependency injection - data should already be loaded from splash screen
    _movieStore = GetIt.instance<MovieStore>();
    _userStore = GetIt.instance<UserStore>();
    
    // Add scroll listener for dynamic preloading
    _scrollController.addListener(_onScroll);
    
    // Fetch 9 movies for each genre
    _movieStore.fetchAllCategoryMovies();
    
    // Select Action genre by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectActionGenreByDefault();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _genreScrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    _movieStore.preloadNextBatchOnScroll(context, _scrollController);
    _detectCurrentCategory();
  }
  
  void _detectCurrentCategory() {
    if (_isSearching || _movieStore.genres.isEmpty) {
      return;
    }
    
    // Get the current scroll position
    final scrollPosition = _scrollController.position.pixels;
    
    // Calculate the estimated visible index based on item height
    final itemHeight = MediaQuery.of(context).size.height * 0.67;
    final estimatedIndex = (scrollPosition / itemHeight).floor();
    
    // Ensure the index is within bounds
    if (estimatedIndex >= 0 && estimatedIndex < _movieStore.genres.length) {
      final visibleGenreId = _movieStore.genres[estimatedIndex].id;
      
      // Update the selected genre if it's different from the current one
      if (visibleGenreId != _selectedGenreForScroll) {
        setState(() {
          _selectedGenreForScroll = visibleGenreId;
        });
        
        // Scroll the genre chips to keep the selected one visible
        _scrollGenreChipToCenter(visibleGenreId);
      }
    }
  }
  
  void _scrollGenreChipToCenter(int genreId) {
    final genreIndex = _movieStore.genres.indexWhere((g) => g.id == genreId);
    if (genreIndex >= 0 && _genreScrollController.hasClients) {
      // Calculate the position to scroll to
      final itemWidth = 100.0; // Approximate width of each chip
      final spacing = 8.0;
      final position = genreIndex * (itemWidth + spacing);
      
      // Get the center position
      final screenWidth = MediaQuery.of(context).size.width;
      final target = math.max(0, position - (screenWidth / 2) + (itemWidth / 2));
      
      // Only scroll if the target is not already visible
      if (target < _genreScrollController.offset || 
          target > (_genreScrollController.offset + screenWidth - itemWidth)) {
        _genreScrollController.animateTo(
          target.toDouble(),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _toggleGenreSelection(MovieGenre genre) {
    setState(() {
      _selectedGenreForScroll = genre.id;
    });
    
    // Only fetch if we don't already have movies for this genre
    if (!_movieStore.categoryMovies.containsKey(genre.id) || 
        _movieStore.categoryMovies[genre.id]!.isEmpty) {
      _movieStore.fetchMoviesForGenre(genre.id);
    }
    
    // Find the index of the genre in the list
    final genreIndex = _movieStore.genres.indexWhere((g) => g.id == genre.id);
    if (genreIndex >= 0) {
      // Calculate approximate position to scroll to
      final itemHeight = MediaQuery.of(context).size.height * 0.67; // Approximate height of a genre section
      final scrollPosition = genreIndex * itemHeight;
      
      // Scroll to the position
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      
      // Don't reset the selection - keep it highlighted
    }
  }

  void _handleSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
    } else {
      setState(() {
        _isSearching = true;
      });
      _movieStore.searchMovies(query);
    }
  }

  // Helper method to select Action genre by default
  void _selectActionGenreByDefault() {
    if (_movieStore.genres.isNotEmpty) {
      // Find the Action genre or default to first genre
      final actionGenre = _movieStore.genres.firstWhere(
        (genre) => genre.name.toLowerCase() == 'action',
        orElse: () => _movieStore.genres.first,
      );
      
      // Set it as selected
      setState(() {
        _selectedGenreForScroll = actionGenre.id;
      });
      
      // Wait a bit for the UI to be ready, then scroll to it
      Future.delayed(const Duration(milliseconds: 300), () {
        _toggleGenreSelection(actionGenre);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with "For You" title and star icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Text(
                    'For You',
                    style: AppTextStyles.heading1,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '⭐',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            
            // Suggested movies in circular format (For You section)
            _buildForYouMovies(),
            
            // Divider between recommended films and Movies section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            
            // Movies section
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
              child: Row(
                children: [
                  Text(
                    'Movies',
                    style: AppTextStyles.heading1,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '🎬',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            
            // Search bar moved above genre chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.grey,
                  ),
                  suffixIcon: const Icon(
                    Icons.mic,
                    color: AppColors.grey,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                ),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.black,
                ),
                onChanged: _handleSearch,
              ),
            ),
            
            // Genre Chips
            _buildGenreChips(),
            
            // Main content (categories or search results)
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
                            'Error',
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
                            onPressed: () {
                              // If we have an error, refresh the main data
                              _movieStore.fetchPopularMovies();
                              _movieStore.fetchGenres();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return _isSearching ? _buildSearchResults() : _buildCategoriesSection();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildForYouMovies() {
    return Observer(
      builder: (_) {
        if (_movieStore.popularMovies.isEmpty) {
          return SizedBox(
            height: 90,
            child: Center(
              child: Text(
                'No recommended movies',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
              ),
            ),
          );
        }
        
        return PersonalizedRecommendations(
          onMovieTap: (selectedMovie) {
            // Handle movie tap - navigate to detail screen
            // TODO: Implement navigation to movie detail screen
          },
        );
      },
    );
  }
  
  Widget _buildGenreChips() {
    return Observer(
      builder: (_) {
        if (_movieStore.genres.isEmpty) {
          return const SizedBox(height: 40);
        }
        
        return Container(
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListView.separated(
            controller: _genreScrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _movieStore.genres.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final genre = _movieStore.genres[index];
              final isSelected = _selectedGenreForScroll == genre.id;
              return GenreChip(
                genre: genre,
                isSelected: isSelected,
                onTap: _toggleGenreSelection,
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildCategoriesSection() {
    return Observer(
      builder: (_) {
        final genres = _movieStore.genres;
        if (genres.isEmpty) {
          return const Center(
            child: Text('No genres available'),
          );
        }
        
        return _buildAllCategoriesSection(genres);
      },
    );
  }
  
  Widget _buildAllCategoriesSection(List<MovieGenre> genres) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        // Detect start and end of scrolling for better control
        if (notification is ScrollStartNotification) {
          _isManuallyScrolling = true;
        } else if (notification is ScrollEndNotification) {
          _isManuallyScrolling = false;
          // Detect current category after scroll ends
          _detectCurrentCategory();
        }
        return false; // Allow the notification to continue propagating
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: genres.length,
        itemBuilder: (context, index) {
          return _buildCategorySection(genres[index]);
        },
      ),
    );
  }
  
  Widget _buildCategorySection(MovieGenre genre) {
    return Observer(
      builder: (_) {
        // Check if we have movies for this genre in our map
        final hasMovies = _movieStore.categoryMovies.containsKey(genre.id) && 
                         _movieStore.categoryMovies[genre.id]!.isNotEmpty;
        
        // Check if we're currently loading this genre
        final isLoading = _movieStore.loadingGenres.contains(genre.id);
        
        // If we don't have movies and aren't loading, fetch them now
        if (!hasMovies && !isLoading) {
          _movieStore.fetchMoviesForGenre(genre.id);
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                children: [
                  Text(
                    genre.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: _selectedGenreForScroll == genre.id ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isLoading)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: AppColors.redLight,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (hasMovies)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _movieStore.categoryMovies[genre.id]!.length,
                itemBuilder: (context, index) {
                  final movie = _movieStore.categoryMovies[genre.id]![index];
                  return MovieCard(
                    movie: movie,
                    showTitle: false,
                    curved: false,
                  );
                },
              )
            else
              // Show placeholder grid while loading
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 9, // Always show 9 placeholders
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.greyDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.redLight,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
  
  Widget _buildSearchResults() {
    return Observer(
      builder: (_) {
        if (_movieStore.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.redLight,
            ),
          );
        }
        
        final searchResults = _movieStore.popularMovies;
        
        if (searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppColors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No movies found',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 8),
                Text(
                  'Try different keywords',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        
        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            final movie = searchResults[index];
            return MovieCard(
              movie: movie,
              showTitle: false,
              curved: false,
            );
          },
        );
      },
    );
  }
} 