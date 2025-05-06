import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/movie.dart';

part 'movie_model.g.dart';

@JsonSerializable()
class MovieModel extends Movie {
  MovieModel({
    required int id,
    required String title,
    String? posterPath,
    String? backdropPath,
    required String overview,
    @JsonKey(name: 'vote_average') required double voteAverage,
    @JsonKey(name: 'genre_ids') required List<int> genreIds,
    @JsonKey(name: 'release_date') required String releaseDate,
  }) : super(
    id: id,
    title: title,
    posterPath: posterPath,
    backdropPath: backdropPath,
    overview: overview,
    voteAverage: voteAverage,
    genreIds: genreIds,
    releaseDate: releaseDate,
  );
  
  // Custom fromJson method to handle null values
  static MovieModel fromJson(Map<String, dynamic> json) {
    // Handle posterPath and backdropPath - they might come with different keys from the API
    String? posterPath = json['poster_path'] as String?;
    String? backdropPath = json['backdrop_path'] as String?;
    
    // Handle vote_average which might be null
    double voteAverage = 0.0;
    if (json['vote_average'] != null) {
      voteAverage = (json['vote_average'] as num).toDouble();
    }
    
    // Handle genre_ids which might be null or empty
    List<int> genreIds = [];
    if (json['genre_ids'] != null) {
      genreIds = (json['genre_ids'] as List<dynamic>)
          .map((e) => e == null ? 0 : (e as num).toInt())
          .toList();
    }
    
    // Handle release_date which might be null or empty
    String releaseDate = json['release_date'] as String? ?? '';
    
    return MovieModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? 'Unknown Title',
      posterPath: posterPath,
      backdropPath: backdropPath,
      overview: json['overview'] as String? ?? 'No overview available',
      voteAverage: voteAverage,
      genreIds: genreIds,
      releaseDate: releaseDate,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'poster_path': posterPath,
    'backdrop_path': backdropPath,
    'overview': overview,
    'vote_average': voteAverage,
    'genre_ids': genreIds,
    'release_date': releaseDate,
  };
}

@JsonSerializable()
class MovieGenreModel extends MovieGenre {
  MovieGenreModel({
    required int id,
    required String name,
  }) : super(id: id, name: name);
  
  // Custom fromJson method to handle null values
  static MovieGenreModel fromJson(Map<String, dynamic> json) {
    return MovieGenreModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? 'Unknown',
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

@JsonSerializable()
class MovieListResponse {
  final int page;
  final List<MovieModel> results;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'total_results')
  final int totalResults;
  
  MovieListResponse({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });
  
  factory MovieListResponse.fromJson(Map<String, dynamic> json) {
    return MovieListResponse(
      page: (json['page'] as num).toInt(),
      results: (json['results'] as List<dynamic>)
          .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPages: (json['total_pages'] as num).toInt(),
      totalResults: (json['total_results'] as num).toInt(),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'page': page,
    'results': results,
    'total_pages': totalPages,
    'total_results': totalResults,
  };
}

@JsonSerializable()
class GenreListResponse {
  final List<MovieGenreModel> genres;
  
  GenreListResponse({required this.genres});
  
  factory GenreListResponse.fromJson(Map<String, dynamic> json) {
    return GenreListResponse(
      genres: (json['genres'] as List<dynamic>)
          .map((e) => MovieGenreModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'genres': genres,
  };
} 