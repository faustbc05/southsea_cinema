import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/booking.dart';

void main() {
  test('Booking survives a map round trip', () {
    final booking = Booking(
      bookingNumber: 1004,
      summary: '2 x Berserk (1997)',
      total: 9.98,
      date: '19/11/2026 16:30',
    );

    final serialisedBooking = booking.toMap();
    final deserialisedBooking = Booking.fromMap(serialisedBooking);

    expect(deserialisedBooking.id, booking.id);
    expect(serialisedBooking.containsKey('id'), isFalse);
    expect(deserialisedBooking.bookingNumber, booking.bookingNumber);
    expect(deserialisedBooking.summary, booking.summary);
    expect(deserialisedBooking.total, booking.total);
    expect(deserialisedBooking.date, booking.date);
  });
}
