import 'package:mocktail/mocktail.dart';
import 'package:movie_app/Model/datasources/user_preferences.dart';

class MockUserPreferences extends Mock implements UserPreferences {
  @override
  Future<void> clearAll() async {}
} 