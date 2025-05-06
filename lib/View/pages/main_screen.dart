import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../Model/entities/movie.dart';
import '../../ViewModel/stores/movie_store.dart';
import '../../ViewModel/stores/user_store.dart';
import '../widgets/genre_chip.dart';
import '../widgets/movie_card.dart';

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

  @override
  void initState() {
    super.initState();
    
    // Get stores from dependency injection - data should already be loaded from splash screen
    _movieStore = GetIt.instance<MovieStore>();
    _userStore = GetIt.instance<UserStore>();
    
    // Add scroll listener for dynamic preloading
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    _movieStore.preloadNextBatchOnScroll(context, _scrollController);
  }

  void _toggleGenreSelection(MovieGenre genre) {
    // Set current genre or clear if already selected
    if (_movieStore.currentGenreId == genre.id) {
      _movieStore.currentGenreId = null;
    } else {
      _movieStore.currentGenreId = genre.id;
      
      // Only fetch if we don't already have movies for this genre
      if (_movieStore.moviesByGenre.isEmpty) {
        _movieStore.fetchMoviesByGenre(genre.id);
      }
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
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20,
                  ),
                ],
              ),
            ),
            
            // Suggested movies in circular format (For You section)
            _buildForYouMovies(),
            
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                    borderRadius: BorderRadius.circular(30),
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
            
            // Movies section
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.movie_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Movies',
                    style: AppTextStyles.heading2,
                  ),
                ],
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
        
        // Try to use user's selected genres from onboarding if available
        List<Movie> suggestedMovies;
        
        if (_userStore.selectedGenreIds.isNotEmpty) {
          // Filter movies that match user's selected genres
          suggestedMovies = _movieStore.popularMovies
              .where((movie) => movie.genreIds
                  .any((genreId) => _userStore.selectedGenreIds.contains(genreId)))
              .take(10)
              .toList();
          
          // If no matches found, fallback to popular movies
          if (suggestedMovies.isEmpty) {
            suggestedMovies = _movieStore.popularMovies.take(10).toList();
          }
        } else {
          // No user preferences, use popular movies
          suggestedMovies = _movieStore.popularMovies.take(10).toList();
        }
        
        return Container(
          height: 90,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: suggestedMovies.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final movie = suggestedMovies[index];
              return CircularMovieCard(
                movie: movie,
                size: 70,
                onTap: (selectedMovie) {
                  // Handle circular movie tap
                },
              );
            },
          ),
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
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _movieStore.genres.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final genre = _movieStore.genres[index];
              final isSelected = _movieStore.currentGenreId == genre.id;
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
        
        if (_movieStore.currentGenreId != null) {
          return _buildSelectedGenreSection();
        } else {
          return _buildAllCategoriesSection(genres);
        }
      },
    );
  }
  
  Widget _buildAllCategoriesSection(List<MovieGenre> genres) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: genres.length,
      itemBuilder: (context, index) {
        return _buildCategorySection(genres[index]);
      },
    );
  }
  
  Widget _buildSelectedGenreSection() {
    return Observer(
      builder: (_) {
        final genreId = _movieStore.currentGenreId;
        if (genreId == null) return const SizedBox.shrink();
        
        final genre = _movieStore.genres.firstWhere(
          (g) => g.id == genreId,
          orElse: () => MovieGenre(id: 0, name: 'Unknown'),
        );
        
        if (_movieStore.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  genre.name,
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  color: AppColors.redLight,
                ),
              ],
            ),
          );
        }
        
        // If no movies for this genre, show popular movies instead
        final movies = _movieStore.moviesByGenre.isEmpty 
            ? _movieStore.popularMovies 
            : _movieStore.moviesByGenre;
        
        if (movies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  genre.name,
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 24),
                Text(
                  'No movies found for this genre',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                genre.name,
                style: AppTextStyles.heading3,
              ),
            ),
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return MovieCard(
                    movie: movie,
                    showTitle: false,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildCategorySection(MovieGenre genre) {
    return Observer(
      builder: (_) {
        // Get movies for this category from popular movies
        final allMovies = _movieStore.popularMovies;
        
        // Filter movies for this genre
        final moviesForCategory = allMovies.where((movie) => 
          movie.genreIds.contains(genre.id)
        ).take(9).toList();
        
        // Skip empty categories
        if (moviesForCategory.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                genre.name,
                style: AppTextStyles.heading3,
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: moviesForCategory.length > 9 ? 9 : moviesForCategory.length,
              itemBuilder: (context, index) {
                final movie = moviesForCategory[index];
                return MovieCard(
                  movie: movie,
                  showTitle: false,
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
            );
          },
        );
      },
    );
  }
} 