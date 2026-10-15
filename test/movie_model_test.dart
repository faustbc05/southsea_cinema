import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';

void main() {
  group('Movie model tests', () {
    test('stores the supplied movie properties', () {
      final movie = Movie(
          id: 'dr_stone',
          name: 'Dr. Stone',
          description:
              'A mysterious green flash suddenly petrifies ostensibly all humans. The human race is petrified in stone for 3,719 years until in April 5738, when 15-year-old prodigy Senku Ishigami is suddenly revived...',
          imagePath: 'assets/images/berserk.jpg',
          ticketPrice: 5.9,
          ageRating: '12',
          screeningTime: DateTime(2026, 10, 29, 18, 30),
          runtimeMinutes: 112,
          location: 'Screen 3');

      expect(movie.id, 'dr_stone');
      expect(movie.name, 'Dr. Stone');
      expect(movie.description,
          'A mysterious green flash suddenly petrifies ostensibly all humans. The human race is petrified in stone for 3,719 years until in April 5738, when 15-year-old prodigy Senku Ishigami is suddenly revived...');
      expect(movie.imagePath, 'assets/images/berserk.jpg');
      expect(movie.ticketPrice, 5.9);
      expect(movie.ageRating, '12');
      expect(movie.screeningTime, DateTime(2026, 10, 29, 18, 30));
      expect(movie.runtimeMinutes, 112);
      expect(movie.location, 'Screen 3');
    });

    test('formattedPrice works with a whole-pound price', () {
      final movie = Movie(
          id: 'test',
          name: 'Test Movie',
          description: 'Test description.',
          imagePath: 'assets/images/berserk.jpg',
          ticketPrice: 5.0,
          ageRating: 'TBC',
          screeningTime: DateTime(2011, 1, 1, 10, 15),
          runtimeMinutes: 100,
          location: 'Test Screen');

      expect(movie.formattedPrice, '£5.00');
    });

    test('formattedPrice works with a price with pence', () {
      final movie = Movie(
          id: 'test',
          name: 'Test Movie',
          description: 'Test description.',
          imagePath: 'assets/images/berserk.jpg',
          ticketPrice: 5.9,
          ageRating: 'TBC',
          screeningTime: DateTime(2011, 1, 1, 10, 15),
          runtimeMinutes: 100,
          location: 'Test Screen');

      expect(movie.formattedPrice, '£5.90');
    });
  });
}
