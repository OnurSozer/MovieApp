import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/movie.dart';
import '../../stores/movie_store.dart';
import '../../stores/user_store.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/genre_chip.dart';
import 'subscription_screen.dart';

class GenreSelectionScreen extends StatefulWidget {
  const GenreSelectionScreen({Key? key}) : super(key: key);

  @override
  _GenreSelectionScreenState createState() => _GenreSelectionScreenState();
}

class _GenreSelectionScreenState extends State<GenreSelectionScreen> {
  late MovieStore _movieStore;
  late UserStore _userStore;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    
    // Get stores from dependency injection
    _movieStore = GetIt.instance<MovieStore>();
    _userStore = GetIt.instance<UserStore>();
    
    // Fetch genres if needed (may already be loaded from splash screen)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_movieStore.genres.isEmpty) {
        _fetchGenres();
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchGenres() async {
    await _movieStore.fetchGenres();
  }

  void _toggleGenreSelection(MovieGenre genre) {
    _userStore.toggleSelectedGenre(genre.id);
  }

  void _navigateToNextScreen() {
    if (_userStore.selectedGenreIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one genre'),
          backgroundColor: AppColors.redLight,
        ),
      );
      return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubscriptionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Welcome',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your favorite genres',
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Observer(
                  builder: (_) {
                    if (_movieStore.isLoading && _movieStore.genres.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.redLight,
                        ),
                      );
                    }
                    
                    if (_movieStore.errorMessage != null && _movieStore.genres.isEmpty) {
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
                              'Error loading genres',
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
                              onPressed: _fetchGenres,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    final genres = _movieStore.genres;
                    
                    if (genres.isEmpty) {
                      return const Center(
                        child: Text(
                          'No genres available',
                          style: TextStyle(color: AppColors.white),
                        ),
                      );
                    }
                    
                    return GridView.builder(
                      controller: _scrollController,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: genres.length,
                      itemBuilder: (context, index) {
                        final genre = genres[index];
                        return Observer(
                          builder: (_) {
                            final isSelected = _userStore.selectedGenreIds.contains(genre.id);
                            return GenreCircleChip(
                              genre: genre,
                              isSelected: isSelected,
                              onTap: _toggleGenreSelection,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Continue',
                onPressed: _navigateToNextScreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 