import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

  setUp(() async {
    BasketRepository.instance.clear();

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

  group('BasketView', () {
    testWidgets(
        'Empty basket shows its message without checkout or confirmation',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BasketView(),
      ));

      expect(find.text("Your Basket is Empty"), findsOneWidget);
      expect(find.text("Checkout Successful!"), findsNothing);
      expect(find.text("Checkout"), findsNothing);
    });

    testWidgets('Populated basket displays movie, quantity and total',
        (WidgetTester tester) async {
      BasketItem item = BasketItem(movie: movie1, quantity: 2);
      BasketRepository.instance.addItem(item);
      await tester.pumpWidget(MaterialApp(home: BasketView()));

      expect(find.text('Test Movie 1'), findsOneWidget);
      expect(find.text('Total Ticket Quantity: 2'), findsOneWidget);
      expect(find.text('Total £10.40'), findsOneWidget);
      expect(find.text('Your Basket is Empty'), findsNothing);
    });

    testWidgets('Removal works', (WidgetTester tester) async {
      BasketItem item = BasketItem(movie: movie1, quantity: 2);
      BasketRepository.instance.addItem(item);
      await tester.pumpWidget(MaterialApp(home: BasketView()));
      await tester.tap(find.byTooltip('Remove tickets'));
      await tester.pump();

      expect(find.text('Test Movie 1'), findsNothing);
      expect(find.text('Your Basket is Empty'), findsOneWidget);
      expect(BasketRepository.instance.getItems(), isEmpty);
    });

    testWidgets('Checkout saves booking and clears basket',
        (WidgetTester tester) async {
      final basket = BasketRepository.instance;

      basket.addItem(
        BasketItem(movie: movie1, quantity: 1),
      );

      await tester.pumpWidget(
        const MaterialApp(home: BasketView()),
      );

      await tester.runAsync(() async {
        await tester.tap(find.text('Checkout'));
        await tester.pumpAndSettle();
      });

      await tester.pumpAndSettle();

      expect(find.text('Your Basket is Empty'), findsOneWidget);
      expect(basket.getItems(), isEmpty);
      expect(find.text('Booking #1001 confirmed!'), findsOneWidget);

      final bookings = await tester.runAsync(
        () => CinemaDatabase.instance.getAllBookings(),
      );

      expect(bookings, isNotNull);
      expect(bookings?.length, 1);
      expect(bookings?.first.bookingNumber, 1001);
    });

    testWidgets('Clear basket empties the basket without checkout confirmation',
        (WidgetTester tester) async {
      BasketItem item = BasketItem(movie: movie1, quantity: 1);
      BasketRepository.instance.addItem(item);
      await tester.pumpWidget(MaterialApp(home: BasketView()));
      await tester.tap(find.text('Clear basket'));
      await tester.pump();

      expect(find.text('Your Basket is Empty'), findsOneWidget);
      expect(BasketRepository.instance.getItems(), isEmpty);
      expect(find.text('Checkout Successful!'), findsNothing);
    });

    testWidgets('Empty booking history displays a message',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BasketView(),
      ));
      await tester.pumpAndSettle();

      expect(find.text("No bookings yet"), findsOneWidget);
    });

    testWidgets('Previous bookings appear newest first',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await CinemaDatabase.instance.insertBooking(
          Booking(
            bookingNumber: 1001,
            summary: '1 x Berserk (1997)',
            total: 4.99,
            date: '19/11/2026 12:00',
          ),
        );
        await CinemaDatabase.instance.insertBooking(
          Booking(
            bookingNumber: 1002,
            summary: '2 x Berserk (1997)',
            total: 9.98,
            date: '18/11/2026 12:00',
          ),
        );
      });
      await tester.runAsync(() async {
        await tester.pumpWidget(
          const MaterialApp(home: BasketView()),
        );
        await tester.pumpAndSettle();
      });

      await tester.pump();

      expect(find.text('Booking #1002'), findsOneWidget);
      expect(find.text('Booking #1001'), findsOneWidget);
      final newestY = tester.getTopLeft(find.text('Booking #1002')).dy;
      final oldestY = tester.getTopLeft(find.text('Booking #1001')).dy;

      expect(newestY, lessThan(oldestY));
    });

    testWidgets('Failed checkout preserves the basket',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        final db = await CinemaDatabase.instance.database;
        await db.execute('DROP TABLE bookings');
      });
      BasketRepository.instance.addItem(BasketItem(movie: movie1, quantity: 1));
      await tester.pumpWidget(MaterialApp(
        home: BasketView(),
      ));
      await tester.runAsync(() async {
        await tester.tap(find.text('Checkout'));
        await tester.pumpAndSettle();
      });

      await tester.pumpAndSettle();

      expect(BasketRepository.instance.getTotalItems(), 1);
      expect(find.text('Could not save your booking. Please try again.'),
          findsOneWidget);
    });

    testWidgets('Removing middle film preserves the other two',
        (WidgetTester tester) async {
      Movie movie2 = Movie(
          id: 'test2',
          name: 'test movie 2',
          description: 'second test',
          imagePath: 'assets/images/berserk.jpg',
          ticketPrice: 3.99,
          ageRating: 'U',
          screeningTime: DateTime(2025, 12, 12, 15, 3),
          runtimeMinutes: 115,
          location: 'Test Screen');
      Movie movie3 = Movie(
          id: 'test3',
          name: 'test movie 3',
          description: 'third test',
          imagePath: 'assets/images/berserk.jpg',
          ticketPrice: 4.99,
          ageRating: 'PG',
          screeningTime: DateTime(2025, 11, 12, 15, 3),
          runtimeMinutes: 114,
          location: 'Test Screen');

      BasketRepository.instance.addItem(BasketItem(movie: movie1, quantity: 1));
      BasketRepository.instance.addItem(BasketItem(movie: movie2, quantity: 1));
      BasketRepository.instance.addItem(BasketItem(movie: movie3, quantity: 1));

      await tester.runAsync(() async {
        await tester.pumpWidget(MaterialApp(
          home: BasketView(),
        ));
      });

      await tester.pumpAndSettle();

      expect(BasketRepository.instance.getItems().length, 3);
      expect(find.text(movie1.name), findsOneWidget);
      expect(find.text(movie2.name), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text(movie3.name),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text(movie3.name), findsOneWidget);

      final middleDeleteButton = find.byKey(const ValueKey('remove-test2'));

      await tester.scrollUntilVisible(
        middleDeleteButton,
        -100,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.tap(middleDeleteButton);
      await tester.pumpAndSettle();

      expect(find.text(movie2.name), findsNothing);

      expect(BasketRepository.instance.getItems().length, 2);

      expect(
        BasketRepository.instance
            .getItems()
            .map((item) => item.movie.id)
            .toList(),
        [movie1.id, movie3.id],
      );
    });
  });
}
