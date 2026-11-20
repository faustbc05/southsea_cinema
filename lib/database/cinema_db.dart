import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/booking_item.dart';
import 'package:southsea_cinema/models/basket_item.dart';

class CinemaDatabase {
  CinemaDatabase._internal();

  static final CinemaDatabase instance = CinemaDatabase._internal();

  static Database? _database;

  void setDatabase(Database? db) {
    _database = db;
  }

  Future<Database> get database async {
    final cachedDatabase = _database;

    if (cachedDatabase != null) {
      return cachedDatabase;
    }

    final db = await _initDB('cinema_data.db');
    _database = db;
    return db;
  }

  Future<Database> _initDB(String fileName) async {
    final String folder = await getDatabasesPath();
    final String filePath = join(folder, fileName);
    final Database db = await openDatabase(
      filePath,
      version: 2,
      onConfigure: configureDatabase,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
    return db;
  }

  Future<void> configureDatabase(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> createTables(Database db, int version) async {
    await db.execute("""
    CREATE TABLE IF NOT EXISTS bookings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    booking_number INTEGER NOT NULL,
    summary TEXT NOT NULL,
    total REAL NOT NULL,
    date TEXT NOT NULL
    )
  """);
    await createBookingItemsTable(db);
  }

  Future<void> createBookingItemsTable(Database db) async {
    await db.execute("""
    CREATE TABLE IF NOT EXISTS booking_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      booking_id INTEGER NOT NULL,
      movie_id TEXT NOT NULL,
      movie_name TEXT NOT NULL,
      unit_price REAL NOT NULL,
      quantity INTEGER NOT NULL,
      FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
      CHECK (length(movie_id) > 0),
      CHECK (length(movie_name) > 0),
      CHECK (unit_price >= 0),
      CHECK (quantity > 0)
    )
  """);
    await db.execute("""
      CREATE INDEX IF NOT EXISTS idx_booking_items_booking_id
      ON booking_items(booking_id)
    """);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await createBookingItemsTable(db);
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await createTables(db, version);
    await db.insert('bookings', {
      'booking_number': 1001,
      'summary': '1 x Berserk (1997)',
      'total': 4.99,
      'date': '19/11/2026 12:00',
    });
    await db.insert('bookings', {
      'booking_number': 1002,
      'summary': '2 x Steel Ball Run (2026)',
      'total': 15.98,
      'date': '17/11/2026 11:45',
    });
    await db.insert('bookings', {
      'booking_number': 1003,
      'summary': '2 x Berserk (1997), 3 x Steel Ball Run (2026)',
      'total': 33.95,
      'date': '18/11/2026 10:00',
    });
  }

  Future<int> insertBooking(Booking booking) async {
    final Database db = await database;
    return await db.insert('bookings', booking.toMap());
  }

  Future<int> insertBookingWithItems(
    Booking booking,
    List<BasketItem> items,
  ) async {
    final Database db = await database;

    return db.transaction((txn) async {
      final bookingId = await txn.insert('bookings', booking.toMap());

      for (final item in items) {
        await txn.insert('booking_items', {
          'booking_id': bookingId,
          'movie_id': item.movie.id,
          'movie_name': item.movie.name,
          'unit_price': item.movie.ticketPrice,
          'quantity': item.quantity,
        });
      }

      return bookingId;
    });
  }

  Future<List<BookingItem>> getBookingItems(int bookingId) async {
    final Database db = await database;
    final rows = await db.query(
      'booking_items',
      where: 'booking_id = ?',
      whereArgs: [bookingId],
      orderBy: 'id ASC',
    );

    return rows.map((row) => BookingItem.fromMap(row)).toList();
  }

  Future<List<Booking>> getAllBookings() async {
    final Database db = await database;
    final rows = await db.query('bookings', orderBy: 'booking_number DESC');
    return rows.map((row) => Booking.fromMap(row)).toList();
  }

  Future<int> getNextBookingNumber() async {
    final Database db = await database;

    final rows = await db.rawQuery(
      'SELECT MAX(booking_number) AS max_num FROM bookings',
    );

    final maxValue = rows[0]['max_num'];

    if (maxValue == null) {
      return 1001;
    }

    return (maxValue as int) + 1;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
