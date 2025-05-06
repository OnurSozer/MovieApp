// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MovieStore on _MovieStore, Store {
  late final _$popularMoviesAtom =
      Atom(name: '_MovieStore.popularMovies', context: context);

  @override
  ObservableList<Movie> get popularMovies {
    _$popularMoviesAtom.reportRead();
    return super.popularMovies;
  }

  @override
  set popularMovies(ObservableList<Movie> value) {
    _$popularMoviesAtom.reportWrite(value, super.popularMovies, () {
      super.popularMovies = value;
    });
  }

  late final _$genresAtom = Atom(name: '_MovieStore.genres', context: context);

  @override
  ObservableList<MovieGenre> get genres {
    _$genresAtom.reportRead();
    return super.genres;
  }

  @override
  set genres(ObservableList<MovieGenre> value) {
    _$genresAtom.reportWrite(value, super.genres, () {
      super.genres = value;
    });
  }

  late final _$moviesByGenreAtom =
      Atom(name: '_MovieStore.moviesByGenre', context: context);

  @override
  ObservableList<Movie> get moviesByGenre {
    _$moviesByGenreAtom.reportRead();
    return super.moviesByGenre;
  }

  @override
  set moviesByGenre(ObservableList<Movie> value) {
    _$moviesByGenreAtom.reportWrite(value, super.moviesByGenre, () {
      super.moviesByGenre = value;
    });
  }

  late final _$favoriteMoviesAtom =
      Atom(name: '_MovieStore.favoriteMovies', context: context);

  @override
  ObservableList<Movie> get favoriteMovies {
    _$favoriteMoviesAtom.reportRead();
    return super.favoriteMovies;
  }

  @override
  set favoriteMovies(ObservableList<Movie> value) {
    _$favoriteMoviesAtom.reportWrite(value, super.favoriteMovies, () {
      super.favoriteMovies = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_MovieStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_MovieStore.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$currentGenreIdAtom =
      Atom(name: '_MovieStore.currentGenreId', context: context);

  @override
  int? get currentGenreId {
    _$currentGenreIdAtom.reportRead();
    return super.currentGenreId;
  }

  @override
  set currentGenreId(int? value) {
    _$currentGenreIdAtom.reportWrite(value, super.currentGenreId, () {
      super.currentGenreId = value;
    });
  }

  late final _$preloadedImageUrlsAtom =
      Atom(name: '_MovieStore.preloadedImageUrls', context: context);

  @override
  ObservableSet<String> get preloadedImageUrls {
    _$preloadedImageUrlsAtom.reportRead();
    return super.preloadedImageUrls;
  }

  @override
  set preloadedImageUrls(ObservableSet<String> value) {
    _$preloadedImageUrlsAtom.reportWrite(value, super.preloadedImageUrls, () {
      super.preloadedImageUrls = value;
    });
  }

  late final _$isPreloadingImagesAtom =
      Atom(name: '_MovieStore.isPreloadingImages', context: context);

  @override
  bool get isPreloadingImages {
    _$isPreloadingImagesAtom.reportRead();
    return super.isPreloadingImages;
  }

  @override
  set isPreloadingImages(bool value) {
    _$isPreloadingImagesAtom.reportWrite(value, super.isPreloadingImages, () {
      super.isPreloadingImages = value;
    });
  }

  late final _$currentPreloadPageAtom =
      Atom(name: '_MovieStore.currentPreloadPage', context: context);

  @override
  int get currentPreloadPage {
    _$currentPreloadPageAtom.reportRead();
    return super.currentPreloadPage;
  }

  @override
  set currentPreloadPage(int value) {
    _$currentPreloadPageAtom.reportWrite(value, super.currentPreloadPage, () {
      super.currentPreloadPage = value;
    });
  }

  late final _$fetchPopularMoviesAsyncAction =
      AsyncAction('_MovieStore.fetchPopularMovies', context: context);

  @override
  Future<void> fetchPopularMovies({int page = 1}) {
    return _$fetchPopularMoviesAsyncAction
        .run(() => super.fetchPopularMovies(page: page));
  }

  late final _$fetchAdditionalMoviesAsyncAction =
      AsyncAction('_MovieStore.fetchAdditionalMovies', context: context);

  @override
  Future<void> fetchAdditionalMovies({required int page}) {
    return _$fetchAdditionalMoviesAsyncAction
        .run(() => super.fetchAdditionalMovies(page: page));
  }

  late final _$fetchGenresAsyncAction =
      AsyncAction('_MovieStore.fetchGenres', context: context);

  @override
  Future<void> fetchGenres() {
    return _$fetchGenresAsyncAction.run(() => super.fetchGenres());
  }

  late final _$fetchMoviesByGenreAsyncAction =
      AsyncAction('_MovieStore.fetchMoviesByGenre', context: context);

  @override
  Future<void> fetchMoviesByGenre(int genreId) {
    return _$fetchMoviesByGenreAsyncAction
        .run(() => super.fetchMoviesByGenre(genreId));
  }

  late final _$searchMoviesAsyncAction =
      AsyncAction('_MovieStore.searchMovies', context: context);

  @override
  Future<void> searchMovies(String query) {
    return _$searchMoviesAsyncAction.run(() => super.searchMovies(query));
  }

  late final _$preloadImagesAsyncAction =
      AsyncAction('_MovieStore.preloadImages', context: context);

  @override
  Future<void> preloadImages(BuildContext context, List<Movie> movies,
      {int batchSize = 20}) {
    return _$preloadImagesAsyncAction
        .run(() => super.preloadImages(context, movies, batchSize: batchSize));
  }

  late final _$preloadNextBatchOnScrollAsyncAction =
      AsyncAction('_MovieStore.preloadNextBatchOnScroll', context: context);

  @override
  Future<void> preloadNextBatchOnScroll(
      BuildContext context, ScrollController scrollController) {
    return _$preloadNextBatchOnScrollAsyncAction
        .run(() => super.preloadNextBatchOnScroll(context, scrollController));
  }

  late final _$loadFavoritesAsyncAction =
      AsyncAction('_MovieStore.loadFavorites', context: context);

  @override
  Future<void> loadFavorites() {
    return _$loadFavoritesAsyncAction.run(() => super.loadFavorites());
  }

  late final _$_MovieStoreActionController =
      ActionController(name: '_MovieStore', context: context);

  @override
  void initializeCache() {
    final _$actionInfo = _$_MovieStoreActionController.startAction(
        name: '_MovieStore.initializeCache');
    try {
      return super.initializeCache();
    } finally {
      _$_MovieStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addToFavorites(Movie movie) {
    final _$actionInfo = _$_MovieStoreActionController.startAction(
        name: '_MovieStore.addToFavorites');
    try {
      return super.addToFavorites(movie);
    } finally {
      _$_MovieStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeFromFavorites(Movie movie) {
    final _$actionInfo = _$_MovieStoreActionController.startAction(
        name: '_MovieStore.removeFromFavorites');
    try {
      return super.removeFromFavorites(movie);
    } finally {
      _$_MovieStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
popularMovies: ${popularMovies},
genres: ${genres},
moviesByGenre: ${moviesByGenre},
favoriteMovies: ${favoriteMovies},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
currentGenreId: ${currentGenreId},
preloadedImageUrls: ${preloadedImageUrls},
isPreloadingImages: ${isPreloadingImages},
currentPreloadPage: ${currentPreloadPage}
    ''';
  }
}
