import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';

void main() {
  final Movie movie1 = Movie(
      id: 'test1',
      name: 'Test Movie 1',
      description: 'This is the test movie 1 description',
      imagePath: 'assets/images/berserk.jpg',
      ticketPrice: 5.2,
      ageRating: '18',
      screeningTime: DateTime(2026, 10, 25, 23, 30),
      runtimeMinutes: 120,
      location: 'Screen 1');
  final Movie movie2 = Movie(
      id: 'test2',
      name: 'Test Movie 2',
      description: 'This is the test movie 2 description',
      imagePath: 'assets/images/berserk.jpg',
      ticketPrice: 6.79,
      ageRating: 'U',
      screeningTime: DateTime(2026, 10, 25, 23, 40),
      runtimeMinutes: 140,
      location: 'Screen 2');

  setUp(() {
    BasketRepository.instance.clear();
  });

  group('BasketRepository tests', () {
    test('Basket is empty on initialisation', () {
      expect(BasketRepository.instance.getItems(), isEmpty);
      expect(BasketRepository.instance.getTotalItems(), 0);
      expect(BasketRepository.instance.getTotalDue(), 0.0);
    });

    test('Adding basket items updates quantities and total', () {
      BasketItem item1 = BasketItem(movie: movie1, quantity: 2);
      BasketItem item2 = BasketItem(movie: movie2, quantity: 1);

      BasketRepository.instance.addItem(item1);
      BasketRepository.instance.addItem(item2);

      expect(BasketRepository.instance.getItems().length, 2);
      expect(BasketRepository.instance.getTotalItems(), 3);
      expect(BasketRepository.instance.getTotalDue(), closeTo(17.19, 0.000001));
    });

    test('Removal works correctly', () {
      BasketItem item1 = BasketItem(movie: movie1, quantity: 2);
      BasketItem item2 = BasketItem(movie: movie2, quantity: 1);

      BasketRepository.instance.addItem(item1);
      BasketRepository.instance.addItem(item2);
      BasketRepository.instance.removeItem(0);

      expect(BasketRepository.instance.getItems().length, 1);
      expect(BasketRepository.instance.getTotalItems(), 1);
      expect(BasketRepository.instance.getTotalDue(), 6.79);
      expect(BasketRepository.instance.getItems()[0].movie.id, 'test2');
    });

    test('Clear method works correctly', () {
      BasketItem item1 = BasketItem(movie: movie1, quantity: 2);
      BasketItem item2 = BasketItem(movie: movie2, quantity: 1);

      BasketRepository.instance.addItem(item1);
      BasketRepository.instance.addItem(item2);
      BasketRepository.instance.clear();

      expect(BasketRepository.instance.getItems().length, 0);
      expect(BasketRepository.instance.getTotalItems(), 0);
      expect(BasketRepository.instance.getTotalDue(), 0.0);
    });
  });
}
