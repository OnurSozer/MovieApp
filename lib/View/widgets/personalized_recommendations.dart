import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../Model/entities/movie.dart';
import '../../ViewModel/stores/recommendation_store.dart';

class PersonalizedRecommendations extends StatefulWidget {
  final Function(Movie) onMovieTap;

  const PersonalizedRecommendations({
    Key? key,
    required this.onMovieTap,
  }) : super(key: key);

  @override
  _PersonalizedRecommendationsState createState() => _PersonalizedRecommendationsState();
}

class _PersonalizedRecommendationsState extends State<PersonalizedRecommendations> {
  late RecommendationStore _recommendationStore;

  @override
  void initState() {
    super.initState();
    _recommendationStore = GetIt.instance<RecommendationStore>();
    // Generate recommendations when widget initializes
    _recommendationStore.generateRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        // Create a reaction to watch the recommendations changes
        final isLoading = _recommendationStore.isLoading;
        final hasRecommendations = _recommendationStore.hasRecommendations;
        final recommendationsList = _recommendationStore.recommendations;
        
        if (isLoading) {
          return Container(
            height: 90,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              color: AppColors.redLight,
              strokeWidth: 2,
            ),
          );
        }

        if (!hasRecommendations) {
          return Container(
            height: 90,
            alignment: Alignment.center,
            child: Text(
              'No recommendations available',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
            ),
          );
        }

        return Container(
          height: 90,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: recommendationsList.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final movie = recommendationsList[index];
              return CircularMovieCard(
                movie: movie,
                size: 70,
                onTap: widget.onMovieTap,
              );
            },
          ),
        );
      }
    );
  }
}

class CircularMovieCard extends StatelessWidget {
  final Movie movie;
  final double size;
  final Function(Movie) onTap;

  const CircularMovieCard({
    Key? key,
    required this.movie,
    required this.size,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(movie),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(movie.hasPoster ? movie.fullPosterPath : 'https://via.placeholder.com/70x70?text=No+Image'),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {
              // Fallback for error loading image
              return;
            },
          ),
        ),
      ),
    );
  }
} 