import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/booking_item.dart';

void main() {
  test('BookingItem survives a map round trip', () {
    const item = BookingItem(
      id: 7,
      bookingId: 12,
      movieId: 'berserk',
      movieName: 'Berserk',
      unitPrice: 4.99,
      quantity: 2,
    );

    final map = item.toMap();
    final restored = BookingItem.fromMap(map);

    expect(restored.id, 7);
    expect(restored.bookingId, 12);
    expect(restored.movieId, 'berserk');
    expect(restored.movieName, 'Berserk');
    expect(restored.unitPrice, 4.99);
    expect(restored.quantity, 2);
    expect(restored.lineTotal, 9.98);
  });

  test('BookingItem omits an id before it is inserted', () {
    const item = BookingItem(
      bookingId: 12,
      movieId: 'berserk',
      movieName: 'Berserk',
      unitPrice: 4.99,
      quantity: 2,
    );

    expect(item.toMap().containsKey('id'), isFalse);
  });
}
