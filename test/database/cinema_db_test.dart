import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/models/movie.dart';

void main() {
  setUp(() async {
    sqfliteFfiInit();

    final Database db = await databaseFactoryFfiNoIsolate.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 2,
        onConfigure: CinemaDatabase.instance.configureDatabase,
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
    final List<Map<String, Object?>> itemTables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'booking_items'",
    );
    expect(itemTables, hasLength(1));

    final pragma = await db.rawQuery('PRAGMA foreign_keys');
    expect(pragma.first['foreign_keys'], 1);

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

  test('Fresh database has booking_items constraints and foreign keys',
      () async {
    final Database db = await CinemaDatabase.instance.database;

    final invalidQuantity = db.insert('booking_items', {
      'booking_id': 999999,
      'movie_id': 'film',
      'movie_name': 'Film',
      'unit_price': 5.0,
      'quantity': 0,
    });
    expect(invalidQuantity, throwsA(isA<DatabaseException>()));

    final invalidPrice = db.insert('booking_items', {
      'booking_id': 999999,
      'movie_id': 'film',
      'movie_name': 'Film',
      'unit_price': -1.0,
      'quantity': 1,
    });
    expect(invalidPrice, throwsA(isA<DatabaseException>()));

    final missingBooking = db.insert('booking_items', {
      'booking_id': 999999,
      'movie_id': 'film',
      'movie_name': 'Film',
      'unit_price': 5.0,
      'quantity': 1,
    });
    expect(missingBooking, throwsA(isA<DatabaseException>()));
  });

  test('Version 1 database upgrades in place without changing bookings',
      () async {
    await CinemaDatabase.instance.close();

    final Directory tempDirectory =
        await Directory.systemTemp.createTemp('southsea_cinema_migration_test');
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await databaseFactory.setDatabasesPath(tempDirectory.path);

    addTearDown(() async {
      await CinemaDatabase.instance.close();
      await tempDirectory.delete(recursive: true);
    });

    final dbPath = path.join(tempDirectory.path, 'cinema_data.db');
    final Database versionOne = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: CinemaDatabase.instance.configureDatabase,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE bookings (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              booking_number INTEGER NOT NULL,
              summary TEXT NOT NULL,
              total REAL NOT NULL,
              date TEXT NOT NULL
            )
          ''');
        },
      ),
    );

    await versionOne.insert('bookings', {
      'booking_number': 1042,
      'summary': '2 x Legacy Film',
      'total': 13.98,
      'date': '10/10/2026 09:30',
    });
    await versionOne.close();

    final Database upgraded = await CinemaDatabase.instance.database;

    expect(await upgraded.getVersion(), 2);
    expect(
      await upgraded.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'booking_items'",
      ),
      hasLength(1),
    );

    final rows = await upgraded.query('bookings');
    expect(rows, hasLength(1));
    expect(rows.first['booking_number'], 1042);
    expect(rows.first['summary'], '2 x Legacy Film');
    expect(rows.first['total'], 13.98);
    expect(rows.first['date'], '10/10/2026 09:30');
    expect(await upgraded.query('booking_items'), isEmpty);
  });

  test('Transactional checkout saves booking and all purchase items', () async {
    final movie = Movie(
      id: 'saved-film',
      name: 'Saved Film Name',
      description: 'Description',
      imagePath: 'assets/images/berserk.jpg',
      ticketPrice: 6.75,
      ageRating: '12',
      screeningTime: DateTime(2026, 11, 20, 18, 30),
      runtimeMinutes: 110,
      location: 'Screen 1',
    );

    final bookingId = await CinemaDatabase.instance.insertBookingWithItems(
      const Booking(
        bookingNumber: 1050,
        summary: '2 x Saved Film Name',
        total: 13.50,
        date: '20/11/2026 18:30',
      ),
      [BasketItem(movie: movie, quantity: 2)],
    );

    final bookings = await CinemaDatabase.instance.getAllBookings();
    final items = await CinemaDatabase.instance.getBookingItems(bookingId);

    expect(bookings, hasLength(1));
    expect(bookings.first.bookingNumber, 1050);
    expect(items, hasLength(1));
    expect(items.first.movieId, 'saved-film');
    expect(items.first.movieName, 'Saved Film Name');
    expect(items.first.unitPrice, 6.75);
    expect(items.first.quantity, 2);
    expect(items.first.lineTotal, 13.50);
  });

  test('Transactional checkout rolls back every row when an item fails',
      () async {
    final movie = Movie(
      id: 'rollback-film',
      name: 'Rollback Film',
      description: 'Description',
      imagePath: 'assets/images/berserk.jpg',
      ticketPrice: 5.0,
      ageRating: 'PG',
      screeningTime: DateTime(2026, 11, 20, 18, 30),
      runtimeMinutes: 100,
      location: 'Screen 1',
    );

    expect(
      () => CinemaDatabase.instance.insertBookingWithItems(
        const Booking(
          bookingNumber: 1051,
          summary: '1 x Rollback Film',
          total: 5.0,
          date: '20/11/2026 18:30',
        ),
        [
          BasketItem(movie: movie, quantity: 1),
          BasketItem(movie: movie, quantity: 0),
        ],
      ),
      throwsA(isA<DatabaseException>()),
    );

    final bookings = await CinemaDatabase.instance.getAllBookings();
    final Database db = await CinemaDatabase.instance.database;
    final itemRows = await db.query('booking_items');

    expect(bookings, isEmpty);
    expect(itemRows, isEmpty);
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
