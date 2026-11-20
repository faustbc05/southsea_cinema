import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

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

  test(
      'Lazy initialisation creates the bookings table and seeds first-run data',
      () async {
    await CinemaDatabase.instance.close();

    final Directory tempDirectory =
        await Directory.systemTemp.createTemp('southsea_cinema_db_test');
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await databaseFactory.setDatabasesPath(tempDirectory.path);

    addTearDown(() async {
      await CinemaDatabase.instance.close();
      await tempDirectory.delete(recursive: true);
    });

    final Database db = await CinemaDatabase.instance.database;
    final List<Map<String, Object?>> tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'bookings'",
    );
    expect(tables, hasLength(1));

    final List<Map<String, Object?>> rows =
        await db.query('bookings', orderBy: 'booking_number ASC');
    expect(rows, hasLength(3));
    expect(rows[0]['booking_number'], 1001);
    expect(rows[0]['summary'], '1 x Berserk (1997)');
    expect(rows[0]['total'], 4.99);
    expect(rows[0]['date'], '19/11/2026 12:00');
    expect(rows[1]['booking_number'], 1002);
    expect(rows[1]['summary'], '2 x Steel Ball Run (2026)');
    expect(rows[1]['total'], 15.98);
    expect(rows[1]['date'], '17/11/2026 11:45');
    expect(rows[2]['booking_number'], 1003);
    expect(rows[2]['summary'], '2 x Berserk (1997), 3 x Steel Ball Run (2026)');
    expect(rows[2]['total'], 33.95);
    expect(rows[2]['date'], '18/11/2026 10:00');

    final Database cachedDb = await CinemaDatabase.instance.database;
    expect(cachedDb, same(db));
  });

  test('Opening an existing temporary database does not reseed it', () async {
    await CinemaDatabase.instance.close();

    final Directory tempDirectory =
        await Directory.systemTemp.createTemp('southsea_cinema_reopen_test');
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await databaseFactory.setDatabasesPath(tempDirectory.path);

    addTearDown(() async {
      await CinemaDatabase.instance.close();
      await tempDirectory.delete(recursive: true);
    });

    Database db = await CinemaDatabase.instance.database;
    expect(await db.query('bookings'), hasLength(3));

    await db.close();
    CinemaDatabase.instance.setDatabase(null);

    db = await CinemaDatabase.instance.database;
    expect(await db.query('bookings'), hasLength(3));
  });

  test('Required booking fields produce a database exception', () async {
    final Database db = await CinemaDatabase.instance.database;

    expect(
      () => db.insert('bookings', {
        'booking_number': 1007,
        'summary': null,
        'total': 9.99,
        'date': '20/11/2026 12:00',
      }),
      throwsA(isA<DatabaseException>()),
    );

    expect(await db.query('bookings'), isEmpty);
  });

  test('Closing the database resets the cache and repeated close is a no-op',
      () async {
    final Database db = await CinemaDatabase.instance.database;

    await CinemaDatabase.instance.close();
    await CinemaDatabase.instance.close();

    expect(db.isOpen, isFalse);

    final Directory tempDirectory =
        await Directory.systemTemp.createTemp('southsea_cinema_close_test');
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await databaseFactory.setDatabasesPath(tempDirectory.path);

    addTearDown(() async {
      await CinemaDatabase.instance.close();
      await tempDirectory.delete(recursive: true);
    });

    final Database reopenedDb = await CinemaDatabase.instance.database;
    expect(reopenedDb.isOpen, isTrue);
  });
}
