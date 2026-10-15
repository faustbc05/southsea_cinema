import 'package:southsea_cinema/models/movie.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';

void main() {
  group('Unit tests for movie repository', () {
    test('movie repository contains two movies', () {
      final MovieRepository movieRepository = MovieRepository();

      final List<Movie> movies = movieRepository.getMovies();

      expect(movies.length, 2);
    });

    test('movie data is correct', () {
      final MovieRepository movieRepository = MovieRepository();
      final List<Movie> movies = movieRepository.getMovies();

      final Movie berserk = movies[0];
      expect(berserk.id, 'berserk');
      expect(berserk.name, 'Berserk (1997)');
      expect(berserk.ticketPrice, 4.99);
      expect(berserk.imagePath, isNotEmpty);

      final Movie sbr = movies[1];
      expect(sbr.id, 'steel-ball-run');
      expect(sbr.name, "Steel Ball Run: JoJo's Bizarre Adventure (2026)");
      expect(sbr.ticketPrice, 7.99);
      expect(sbr.imagePath, isNotEmpty);
    });

    test('getMovieById returns the matching movie for an existing ID', () {
      final MovieRepository movieRepository = MovieRepository();
      final Movie? movie = movieRepository.getMovieById('steel-ball-run');

      expect(movie, isNotNull);
      expect(movie?.name, "Steel Ball Run: JoJo's Bizarre Adventure (2026)");
      expect(movie?.ticketPrice, 7.99);
    });

    test('getMovieById returns null when no match is found', () {
      final MovieRepository movieRepository = MovieRepository();
      final Movie? movie = movieRepository.getMovieById('missing-movie');

      expect(movie, isNull);
    });
  });
}
