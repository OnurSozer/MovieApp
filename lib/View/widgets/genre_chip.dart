import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../Model/entities/movie.dart';

class GenreChip extends StatelessWidget {
  final MovieGenre genre;
  final bool isSelected;
  final Function(MovieGenre) onTap;

  const GenreChip({
    Key? key,
    required this.genre,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(genre),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.redLight : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.redLight : AppColors.grey,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              genre.name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GenreCircleChip extends StatelessWidget {
  final MovieGenre genre;
  final bool isSelected;
  final Function(MovieGenre) onTap;
  final double size;

  const GenreCircleChip({
    Key? key,
    required this.genre,
    required this.isSelected,
    required this.onTap,
    this.size = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(genre),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          border: Border.all(
            color: isSelected ? AppColors.selectedCategory : AppColors.white,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Center content with icon and text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIconForGenre(genre.name),
                    color: AppColors.black,
                    size: size / 2.2,
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      genre.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.black,
                        fontSize: size / 5.5,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            if (isSelected)
              Positioned(
                bottom: size / 8,
                right: size / 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.redLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForGenre(String genreName) {
    switch (genreName.toLowerCase()) {
      case 'action':
        return Icons.local_fire_department;
      case 'adventure':
        return Icons.explore;
      case 'animation':
        return Icons.animation;
      case 'comedy':
        return Icons.theater_comedy;
      case 'crime':
        return Icons.gavel;
      case 'documentary':
        return Icons.movie_filter;
      case 'drama':
        return Icons.sentiment_dissatisfied;
      case 'family':
        return Icons.family_restroom;
      case 'fantasy':
        return Icons.auto_awesome;
      case 'history':
        return Icons.history;
      case 'horror':
        return Icons.sentiment_very_dissatisfied;
      case 'music':
        return Icons.music_note;
      case 'mystery':
        return Icons.question_mark;
      case 'romance':
        return Icons.favorite;
      case 'science fiction':
        return Icons.rocket;
      case 'thriller':
        return Icons.local_police;
      case 'war':
        return Icons.military_tech;
      case 'western':
        return Icons.terrain;
      default:
        return Icons.movie;
    }
  }
} 