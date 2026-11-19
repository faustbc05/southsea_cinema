import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:southsea_cinema/models/booking.dart';

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
      version: 1,
      onCreate: _createDB,
    );
    return db;
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
