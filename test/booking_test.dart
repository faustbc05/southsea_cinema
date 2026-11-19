import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/movie.dart';

void main() {
  test('Booking survives a map round trip', () {
    final data = Booking(
        id: 'test',
        items: [
          BasketItem(
              movie: Movie(
                  id: 'test-movie',
                  name: 'Movie',
                  description: 'this is a test',
                  imagePath: 'assets/images/berserk.jpg',
                  ticketPrice: 9.99,
                  ageRating: 'U',
                  screeningTime: DateTime(2026, 2, 2, 17, 30),
                  runtimeMinutes: 119,
                  location: 'Test Screen'),
              quantity: 2)
        ],
        bookedAt: DateTime(2026, 1, 31, 18, 32));

    final serialisedBooking = data.toMap();
    final deserialisedBooking = Booking.fromMap(serialisedBooking);

    expect(deserialisedBooking.id, data.id);
    expect(deserialisedBooking.bookedAt, data.bookedAt);
    expect(deserialisedBooking.items.length, data.items.length);
    expect(deserialisedBooking.items[0].quantity, data.items[0].quantity);
    expect(deserialisedBooking.items[0].movie.name, data.items[0].movie.name);
    expect(deserialisedBooking.items[0].movie.ticketPrice, data.items[0].movie.ticketPrice);
    expect(deserialisedBooking.items[0].movie.screeningTime, data.items[0].movie.screeningTime);
  });
}
