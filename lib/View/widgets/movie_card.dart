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
          // Remove the border condition entirely
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
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
      // Use MediaQuery for responsive sizing
      final width = MediaQuery.of(context).size.width * 0.55;
      final height = MediaQuery.of(context).size.height * 0.35;
      final curveDepth = height * 0.04; // 12% of the card height
      return ClipPath(
        clipper: CylinderClipper(curveDepth: curveDepth),
        child: CachedNetworkImage(
          imageUrl: widget.movie.fullPosterPath,
          width: width,
          height: height,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildLoadingPlaceholder(),
          errorWidget: (context, url, error) => _buildErrorPlaceholder(),
        ),
      );
    } else {
      return _buildErrorPlaceholder();
    }
  }
  
  Widget _buildLoadingPlaceholder() {
    return Stack(
      children: [
        Container(
          color: AppColors.greyDark,
        ),
        const Center(
          child: CircularProgressIndicator(
            color: AppColors.redLight,
            strokeWidth: 2,
          ),
        ),
      ],
    );
  }
  
  Widget _buildErrorPlaceholder() {
    return Stack(
      children: [
        Container(
          color: AppColors.greyDark,
        ),
        Center(
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
      ],
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
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Remove the border condition entirely
        ),
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
    return Stack(
      children: [
        Container(
          color: AppColors.greyDark,
        ),
        const Center(
          child: CircularProgressIndicator(
            color: AppColors.redLight,
            strokeWidth: 2,
          ),
        ),
      ],
    );
  }
  
  Widget _buildErrorPlaceholder() {
    return Stack(
      children: [
        Container(
          color: AppColors.greyDark,
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.movie_outlined,
                color: AppColors.white.withOpacity(0.7),
                size: widget.size / 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom clipper for cylinder-like curved edges
class CylinderClipper extends CustomClipper<Path> {
  final double curveDepth;
  const CylinderClipper({this.curveDepth = 30}); // Default value

  @override
  Path getClip(Size size) {
    final path = Path();
    // Top inward curve (concave)
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, curveDepth, size.width, 0);
    // Right side
    path.lineTo(size.width, size.height);
    // Bottom inward curve (concave)r
    path.quadraticBezierTo(size.width / 2, size.height - curveDepth, 0, size.height);
    // Left side
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CylinderClipper oldClipper) => curveDepth != oldClipper.curveDepth;
} 
