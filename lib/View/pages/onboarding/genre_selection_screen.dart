import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../Model/entities/movie.dart';
import '../../../ViewModel/stores/movie_store.dart';
import '../../../ViewModel/stores/user_store.dart';
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
  
  // Required number of genre selections
  static const int requiredSelections = 2;
  
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
    // If user is trying to select more than the required number of genres
    if (_userStore.selectedGenreIds.length >= requiredSelections && 
        !_userStore.selectedGenreIds.contains(genre.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can only select $requiredSelections genres'),
          backgroundColor: AppColors.redLight,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    _userStore.toggleSelectedGenre(genre.id);
  }

  void _navigateToNextScreen() {
    if (_userStore.selectedGenreIds.length != requiredSelections) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select exactly $requiredSelections favorite genres'),
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
        child: Stack(
          children: [
            // Main content including GridView
            Padding(
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
                  Observer(
                    builder: (_) {
                      return Text(
                        'Choose your $requiredSelections favorite genres',
                        style: AppTextStyles.bodyLarge,
                      );
                    },
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
                            crossAxisCount: 2,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 26,
                            mainAxisSpacing: 22,
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
                ],
              ),
            ),
            // Floating continue button
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 42),
                child: Observer(
                  builder: (_) {
                    final hasRequiredSelections = _userStore.selectedGenreIds.length == requiredSelections;
                    return PrimaryButton(
                      text: 'Continue',
                      onPressed: hasRequiredSelections ? _navigateToNextScreen : null,
                      backgroundColor: AppColors.redLight,
                      disabledBackgroundColor: AppColors.redDark,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 