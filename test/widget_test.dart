import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/views/movie_listing.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';

void main() {
  setUp(() {
    BasketRepository.instance.clear();
  });
  group('Cinema app widget tests', () {
    testWidgets('Home page displays its title, movie cards and booking buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());
      expect(find.text('Southsea Cinema & Arts Centre'), findsOneWidget);
      expect(find.byType(MovieCard), findsNWidgets(2));
      expect(find.text('Book Tickets'), findsNWidgets(2));
    });

    testWidgets('Tapping Book Tickets opens the movie listing',
        (WidgetTester tester) async {
      await tester.pumpWidget(SouthseaCinemaApp());
      await tester.tap(find.text('Book Tickets').first);
      await tester.pumpAndSettle();

      expect(find.byType(MovieListing), findsOneWidget);
      expect(find.text("Screen 1"), findsOneWidget);
      expect(find.text("Runtime: 90 minutes"), findsOneWidget);

      await tester.tap(find.text('ADD TO ORDER'));
      await tester.pump();

      expect(
          find.text('please select a ticket quantity to add'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Book Tickets'), findsNWidgets(2));

      await tester.ensureVisible(find.text('Book Tickets').last);
      await tester.pump();
      await tester.tap(find.text('Book Tickets').last);
      await tester.pumpAndSettle();

      expect(find.text('Screen 2'), findsOneWidget);
      expect(find.text('please select a ticket quantity to add'), findsNothing);
    });

    testWidgets('Hamburger menu opens the navigation drawer',
        (WidgetTester tester) async {
      await tester.pumpWidget(SouthseaCinemaApp());
      await tester.tap(find.text("Book Tickets").first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
          isTrue);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
          isFalse);
    });

    testWidgets('Adding selected tickets stores them in the shared basket',
        (WidgetTester tester) async {
      await tester.pumpWidget(SouthseaCinemaApp());
      await tester.tap(find.text("Book Tickets").first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownMenu<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1').hitTestable());
      await tester.pumpAndSettle();
      await tester.tap(find.text('ADD TO ORDER'));
      await tester.pump();

      expect(find.text("1 ticket(s) added to your order"), findsOneWidget);
      expect(BasketRepository.instance.getItems().length, 1);
      expect(BasketRepository.instance.getItems()[0].movie.id, 'berserk');
      expect(BasketRepository.instance.getItems()[0].quantity, 1);
      expect(BasketRepository.instance.getTotalDue(), 4.99);
    });
  });
}
