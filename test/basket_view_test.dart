import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/models/movie.dart';

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

  setUp(() {
    BasketRepository.instance.clear();
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

    testWidgets('Checkout empties the basket and displays confirmation',
        (WidgetTester tester) async {
      BasketItem item = BasketItem(movie: movie1, quantity: 1);
      BasketRepository.instance.addItem(item);
      await tester.pumpWidget(MaterialApp(home: BasketView()));
      await tester.tap(find.text('Checkout'));
      await tester.pump();

      expect(find.text('Your Basket is Empty'), findsOneWidget);
      expect(BasketRepository.instance.getItems(), isEmpty);
      expect(find.text('Checkout Successful!'), findsOneWidget);
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
  });
}
