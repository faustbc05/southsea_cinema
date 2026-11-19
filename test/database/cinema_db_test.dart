import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUp(() async {
    sqfliteFfiInit();

    final Database db = await databaseFactoryFfiNoIsolate.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: CinemaDatabase.instance.createTables,
      ),
    );

    CinemaDatabase.instance.setDatabase(db);
  });

  tearDown(() async {
    await CinemaDatabase.instance.close();
  });

  test('Inserting and retrieving bookings works', () async {
    Booking booking = Booking(
        bookingNumber: 1001,
        summary: "3 X Steel Ball Run (2026)",
        total: 23.97,
        date: "19/10/2026 11:00");

    await CinemaDatabase.instance.insertBooking(booking);

    List<Booking> result = await CinemaDatabase.instance.getAllBookings();

    expect(result.length, 1);
    expect(result[0].id, isPositive);
    expect(result[0].summary, booking.summary);
    expect(result[0].total, booking.total);
  });

  test('Booking number generation works', () async {
    int nextBookingNum = await CinemaDatabase.instance.getNextBookingNumber();
    expect(nextBookingNum, 1001);

    Booking booking = Booking(
        bookingNumber: 1005,
        summary: "3 X Steel Ball Run (2026)",
        total: 23.97,
        date: "19/10/2026 11:00");

    await CinemaDatabase.instance.insertBooking(booking);

    nextBookingNum = await CinemaDatabase.instance.getNextBookingNumber();
    expect(nextBookingNum, 1006);
  });

  test('There is a descending booking order', () async {
    Booking booking1 = Booking(
        bookingNumber: 1001,
        summary: "2 X Steel Ball Run (2026)",
        total: 15.99,
        date: "19/10/2026 11:00");
    Booking booking2 = Booking(
        bookingNumber: 1003,
        summary: "3 X Steel Ball Run (2026)",
        total: 23.97,
        date: "19/10/2026 11:10");
    Booking booking3 = Booking(
        bookingNumber: 1002,
        summary: "1 X Steel Ball Run (2026)",
        total: 7.99,
        date: "19/10/2026 11:20");

    await CinemaDatabase.instance.insertBooking(booking1);
    await CinemaDatabase.instance.insertBooking(booking2);
    await CinemaDatabase.instance.insertBooking(booking3);

    List<Booking> bookings = await CinemaDatabase.instance.getAllBookings();

    expect(bookings.length, 3);
    int number = 1003;
    for (Booking booking in bookings) {
      expect(booking.bookingNumber, number);
      number--;
    }
  });
}
