// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovieModel _$MovieModelFromJson(Map<String, dynamic> json) => MovieModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      posterPath: json['posterPath'] as String?,
      backdropPath: json['backdropPath'] as String?,
      overview: json['overview'] as String,
      voteAverage: (json['voteAverage'] as num).toDouble(),
      genreIds: (json['genreIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      releaseDate: json['releaseDate'] as String,
    );

Map<String, dynamic> _$MovieModelToJson(MovieModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'posterPath': instance.posterPath,
      'backdropPath': instance.backdropPath,
      'overview': instance.overview,
      'voteAverage': instance.voteAverage,
      'genreIds': instance.genreIds,
      'releaseDate': instance.releaseDate,
    };

MovieGenreModel _$MovieGenreModelFromJson(Map<String, dynamic> json) =>
    MovieGenreModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$MovieGenreModelToJson(MovieGenreModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

MovieListResponse _$MovieListResponseFromJson(Map<String, dynamic> json) =>
    MovieListResponse(
      page: (json['page'] as num).toInt(),
      results: (json['results'] as List<dynamic>)
          .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPages: (json['total_pages'] as num).toInt(),
      totalResults: (json['total_results'] as num).toInt(),
    );

Map<String, dynamic> _$MovieListResponseToJson(MovieListResponse instance) =>
    <String, dynamic>{
      'page': instance.page,
      'results': instance.results,
      'total_pages': instance.totalPages,
      'total_results': instance.totalResults,
    };

GenreListResponse _$GenreListResponseFromJson(Map<String, dynamic> json) =>
    GenreListResponse(
      genres: (json['genres'] as List<dynamic>)
          .map((e) => MovieGenreModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GenreListResponseToJson(GenreListResponse instance) =>
    <String, dynamic>{
      'genres': instance.genres,
    };
