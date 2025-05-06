import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../Model/entities/movie.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;
  final Function? onTap;
  final bool isSelected;
  final bool showTitle;

  const MovieCard({
    Key? key,
    required this.movie,
    this.onTap,
    this.isSelected = false,
    this.showTitle = false,
  }) : super(key: key);

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Initial state
    if (widget.isSelected) {
      _animationController.value = 1.0;
    }
  }
  
  @override
  void didUpdateWidget(MovieCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate when selection state changes
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap != null ? () => widget.onTap!(widget.movie) : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: widget.isSelected
              ? Border.all(color: AppColors.selectedItem, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildMovieImage(),
                    
                    // Radial gradient overlay with animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.8,
                            colors: [
                              Colors.transparent,
                              AppColors.redLight.withOpacity(0.1),
                              AppColors.redLight.withOpacity(0.3),
                              AppColors.redLight.withOpacity(0.5),
                            ],
                            stops: const [0.4, 0.6, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ),
                    
                    // Animated checkmark circle
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.showTitle)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  widget.movie.title,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMovieImage() {
    if (widget.movie.hasPoster) {
      return CachedNetworkImage(
        imageUrl: widget.movie.fullPosterPath,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorPlaceholder(),
      );
    } else {
      return _buildErrorPlaceholder();
    }
  }
  
  Widget _buildLoadingPlaceholder() {
    return Container(
      color: AppColors.greyDark,
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.redLight,
          strokeWidth: 2,
        ),
      ),
    );
  }
  
  Widget _buildErrorPlaceholder() {
    return Container(
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
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularMovieCard extends StatefulWidget {
  final Movie movie;
  final Function? onTap;
  final bool isSelected;
  final double size;

  const CircularMovieCard({
    Key? key,
    required this.movie,
    this.onTap,
    this.isSelected = false,
    this.size = 80,
  }) : super(key: key);

  @override
  State<CircularMovieCard> createState() => _CircularMovieCardState();
}

class _CircularMovieCardState extends State<CircularMovieCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Initial state
    if (widget.isSelected) {
      _animationController.value = 1.0;
    }
  }
  
  @override
  void didUpdateWidget(CircularMovieCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate when selection state changes
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap != null ? () => widget.onTap!(widget.movie) : null,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: widget.isSelected
              ? Border.all(color: AppColors.selectedItem, width: 2)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.size / 2),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildMovieImage(),
              
              // Radial gradient overlay with animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,
                      colors: [
                        Colors.transparent,
                        AppColors.redLight.withOpacity(0.1),
                        AppColors.redLight.withOpacity(0.3),
                        AppColors.redLight.withOpacity(0.5),
                      ],
                      stops: const [0.4, 0.6, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
              
              // Animated checkmark circle
              FadeTransition(
                opacity: _fadeAnimation,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.redLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check,
                          color: AppColors.white,
                          size: 10,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMovieImage() {
    if (widget.movie.hasPoster) {
      return CachedNetworkImage(
        imageUrl: widget.movie.fullPosterPath,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorPlaceholder(),
      );
    } else {
      return _buildErrorPlaceholder();
    }
  }
  
  Widget _buildLoadingPlaceholder() {
    return Container(
      color: AppColors.greyDark,
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.redLight,
          strokeWidth: 2,
        ),
      ),
    );
  }
  
  Widget _buildErrorPlaceholder() {
    return Container(
      color: AppColors.greyDark,
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          color: AppColors.white.withOpacity(0.7),
          size: widget.size / 2,
        ),
      ),
    );
  }
} 
