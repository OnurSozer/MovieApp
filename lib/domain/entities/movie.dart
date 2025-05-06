class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final List<int> genreIds;
  final String releaseDate;
  
  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.genreIds,
    required this.releaseDate,
  });
  
  String get fullPosterPath {
    if (posterPath == null || posterPath!.isEmpty) {
      return '';  // Return empty string for null or empty poster path
    }
    
    // If posterPath doesn't start with "/", add it (sometimes API returns paths without leading slash)
    String normalizedPath = posterPath!.startsWith('/') ? posterPath! : '/$posterPath';
    return 'https://image.tmdb.org/t/p/w500$normalizedPath';
  }
  
  String get fullBackdropPath {
    if (backdropPath == null || backdropPath!.isEmpty) {
      return '';  // Return empty string for null or empty backdrop path
    }
    
    // If backdropPath doesn't start with "/", add it
    String normalizedPath = backdropPath!.startsWith('/') ? backdropPath! : '/$backdropPath';
    return 'https://image.tmdb.org/t/p/w500$normalizedPath';
  }
  
  bool get hasPoster => posterPath != null && posterPath!.isNotEmpty;
  bool get hasBackdrop => backdropPath != null && backdropPath!.isNotEmpty;
}

class MovieGenre {
  final int id;
  final String name;
  
  MovieGenre({required this.id, required this.name});
} 