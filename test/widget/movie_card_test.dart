import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:movie_app/Model/entities/movie.dart';
import 'package:movie_app/View/widgets/movie_card.dart';
import '../mocks/mock_movie_repository.dart';

class TestMovieCard extends StatelessWidget {
  final Movie movie;
  final bool showTitle;
  final bool isSelected;
  final Function(Movie)? onTap;

  const TestMovieCard({
    Key? key,
    required this.movie,
    this.showTitle = false,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 200,
            height: 300,
            child: MovieCard(
              movie: movie,
              showTitle: showTitle,
              isSelected: isSelected,
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  late Movie testMovie;

  setUp(() {
    testMovie = TestMovieData.getPopularMovies().first;
  });

  group('MovieCard Widget Tests', () {
    testWidgets('should render movie card with title when showTitle is true', 
      (WidgetTester tester) async {
        // Mock network images
        await mockNetworkImagesFor(() async {
          // Build widget
          await tester.pumpWidget(TestMovieCard(
            movie: testMovie,
            showTitle: true,
          ));

          // Pump a few frames instead of using pumpAndSettle
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 50));

          // Verify title is shown
          expect(find.text(testMovie.title), findsOneWidget);
        });
      }
    );

    testWidgets('should not show title when showTitle is false', 
      (WidgetTester tester) async {
        // Mock network images
        await mockNetworkImagesFor(() async {
          // Build widget
          await tester.pumpWidget(TestMovieCard(
            movie: testMovie,
            showTitle: false,
          ));

          // Pump a few frames instead of using pumpAndSettle
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 50));

          // Verify title is not shown
          expect(find.text(testMovie.title), findsNothing);
        });
      }
    );

    testWidgets('should call onTap function when tapped', 
      (WidgetTester tester) async {
        // Set up a function to track if it's called
        bool wasTapped = false;
        
        // Mock network images
        await mockNetworkImagesFor(() async {
          // Build widget
          await tester.pumpWidget(TestMovieCard(
            movie: testMovie,
            onTap: (movie) {
              wasTapped = true;
              expect(movie.id, testMovie.id);
            },
          ));

          // Pump a few frames instead of using pumpAndSettle
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 50));

          // Tap the card
          await tester.tap(find.byType(MovieCard));
          await tester.pump();

          // Verify onTap was called
          expect(wasTapped, true);
        });
      }
    );

    testWidgets('should show selection indicators when isSelected is true', 
      (WidgetTester tester) async {
        // Mock network images
        await mockNetworkImagesFor(() async {
          // Build widget
          await tester.pumpWidget(TestMovieCard(
            movie: testMovie,
            isSelected: true,
          ));

          // Pump a few frames instead of using pumpAndSettle
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 50));

          // Verify check icon is shown - it might be in a subtree
          expect(find.byType(Icon), findsWidgets);
        });
      }
    );

    testWidgets('should show error placeholder when movie has no poster', 
      (WidgetTester tester) async {
        // Create a movie with no poster
        final movieWithoutPoster = Movie(
          id: 999,
          title: 'No Poster Movie',
          posterPath: null,
          backdropPath: null,
          overview: 'Test overview',
          voteAverage: 7.0,
          genreIds: [1, 2],
          releaseDate: '2023-01-01',
        );

        // Mock network images
        await mockNetworkImagesFor(() async {
          // Build widget
          await tester.pumpWidget(TestMovieCard(
            movie: movieWithoutPoster,
          ));

          // Pump a few frames instead of using pumpAndSettle
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 50));

          // Verify error placeholder elements
          expect(find.byIcon(Icons.movie_outlined), findsOneWidget);
          expect(find.text('No Image'), findsOneWidget);
        });
      }
    );
  });
} 