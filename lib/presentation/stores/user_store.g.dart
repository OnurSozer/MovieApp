// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserStore on _UserStore, Store {
  late final _$favoriteMovieIdsAtom =
      Atom(name: '_UserStore.favoriteMovieIds', context: context);

  @override
  ObservableList<int> get favoriteMovieIds {
    _$favoriteMovieIdsAtom.reportRead();
    return super.favoriteMovieIds;
  }

  @override
  set favoriteMovieIds(ObservableList<int> value) {
    _$favoriteMovieIdsAtom.reportWrite(value, super.favoriteMovieIds, () {
      super.favoriteMovieIds = value;
    });
  }

  late final _$selectedGenreIdsAtom =
      Atom(name: '_UserStore.selectedGenreIds', context: context);

  @override
  ObservableList<int> get selectedGenreIds {
    _$selectedGenreIdsAtom.reportRead();
    return super.selectedGenreIds;
  }

  @override
  set selectedGenreIds(ObservableList<int> value) {
    _$selectedGenreIdsAtom.reportWrite(value, super.selectedGenreIds, () {
      super.selectedGenreIds = value;
    });
  }

  late final _$isOnboardingCompletedAtom =
      Atom(name: '_UserStore.isOnboardingCompleted', context: context);

  @override
  bool get isOnboardingCompleted {
    _$isOnboardingCompletedAtom.reportRead();
    return super.isOnboardingCompleted;
  }

  @override
  set isOnboardingCompleted(bool value) {
    _$isOnboardingCompletedAtom.reportWrite(value, super.isOnboardingCompleted,
        () {
      super.isOnboardingCompleted = value;
    });
  }

  late final _$subscriptionStatusAtom =
      Atom(name: '_UserStore.subscriptionStatus', context: context);

  @override
  String get subscriptionStatus {
    _$subscriptionStatusAtom.reportRead();
    return super.subscriptionStatus;
  }

  @override
  set subscriptionStatus(String value) {
    _$subscriptionStatusAtom.reportWrite(value, super.subscriptionStatus, () {
      super.subscriptionStatus = value;
    });
  }

  late final _$initPreferencesAsyncAction =
      AsyncAction('_UserStore.initPreferences', context: context);

  @override
  Future<void> initPreferences() {
    return _$initPreferencesAsyncAction.run(() => super.initPreferences());
  }

  late final _$addFavoriteMovieAsyncAction =
      AsyncAction('_UserStore.addFavoriteMovie', context: context);

  @override
  Future<void> addFavoriteMovie(Movie movie) {
    return _$addFavoriteMovieAsyncAction
        .run(() => super.addFavoriteMovie(movie));
  }

  late final _$removeFavoriteMovieAsyncAction =
      AsyncAction('_UserStore.removeFavoriteMovie', context: context);

  @override
  Future<void> removeFavoriteMovie(int movieId) {
    return _$removeFavoriteMovieAsyncAction
        .run(() => super.removeFavoriteMovie(movieId));
  }

  late final _$toggleFavoriteMovieAsyncAction =
      AsyncAction('_UserStore.toggleFavoriteMovie', context: context);

  @override
  Future<void> toggleFavoriteMovie(Movie movie) {
    return _$toggleFavoriteMovieAsyncAction
        .run(() => super.toggleFavoriteMovie(movie));
  }

  late final _$addSelectedGenreAsyncAction =
      AsyncAction('_UserStore.addSelectedGenre', context: context);

  @override
  Future<void> addSelectedGenre(int genreId) {
    return _$addSelectedGenreAsyncAction
        .run(() => super.addSelectedGenre(genreId));
  }

  late final _$removeSelectedGenreAsyncAction =
      AsyncAction('_UserStore.removeSelectedGenre', context: context);

  @override
  Future<void> removeSelectedGenre(int genreId) {
    return _$removeSelectedGenreAsyncAction
        .run(() => super.removeSelectedGenre(genreId));
  }

  late final _$toggleSelectedGenreAsyncAction =
      AsyncAction('_UserStore.toggleSelectedGenre', context: context);

  @override
  Future<void> toggleSelectedGenre(int genreId) {
    return _$toggleSelectedGenreAsyncAction
        .run(() => super.toggleSelectedGenre(genreId));
  }

  late final _$completeOnboardingAsyncAction =
      AsyncAction('_UserStore.completeOnboarding', context: context);

  @override
  Future<void> completeOnboarding() {
    return _$completeOnboardingAsyncAction
        .run(() => super.completeOnboarding());
  }

  late final _$updateSubscriptionAsyncAction =
      AsyncAction('_UserStore.updateSubscription', context: context);

  @override
  Future<void> updateSubscription(String status) {
    return _$updateSubscriptionAsyncAction
        .run(() => super.updateSubscription(status));
  }

  @override
  String toString() {
    return '''
favoriteMovieIds: ${favoriteMovieIds},
selectedGenreIds: ${selectedGenreIds},
isOnboardingCompleted: ${isOnboardingCompleted},
subscriptionStatus: ${subscriptionStatus}
    ''';
  }
}
