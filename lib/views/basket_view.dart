import 'package:material_ui/material_ui.dart';
import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking_item.dart';

class BasketView extends StatefulWidget {
  const BasketView({super.key});

  @override
  State<BasketView> createState() => _BasketViewState();
}

class _BasketViewState extends State<BasketView> {
  String _confirmationMessage = '';
  List<Booking> _bookings = [];
  Map<int, List<BookingItem>> _bookingItems = {};
  bool _loadingBookings = true;
  String? _bookingError;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final bookings = await CinemaDatabase.instance.getAllBookings();
      final bookingItems = <int, List<BookingItem>>{};

      for (final booking in bookings) {
        if (booking.id != null) {
          bookingItems[booking.id!] =
              await CinemaDatabase.instance.getBookingItems(booking.id!);
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _bookings = bookings;
        _bookingItems = bookingItems;
        _loadingBookings = false;
        _bookingError = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadingBookings = false;
        _bookingError = 'Could not load bookings: $error';
      });
    }
  }

  Future<void> _checkout() async {
    final basket = BasketRepository.instance;

    if (basket.getItems().isEmpty) {
      return;
    }

    try {
      final bookingNumber =
          await CinemaDatabase.instance.getNextBookingNumber();

      final summary = basket
          .getItems()
          .map((item) => '${item.quantity} x ${item.movie.name}')
          .join(', ');

      final total = basket.getTotalDue();
      final date = DateTime.now().toIso8601String();

      final booking = Booking(
        bookingNumber: bookingNumber,
        summary: summary,
        total: total,
        date: date,
      );

      await CinemaDatabase.instance.insertBookingWithItems(
        booking,
        basket.getItems(),
      );

      if (!mounted) return;

      setState(() {
        basket.clear();
        _confirmationMessage = 'Booking #$bookingNumber confirmed!';
      });
      await _loadBookings();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _confirmationMessage = 'Could not save your booking. Please try again.';
      });
    }
  }

  Widget _buildBookingHistory() {
    if (_loadingBookings) {
      return CircularProgressIndicator();
    } else if (_bookingError != null) {
      return Center(
        child: Text(_bookingError!),
      );
    } else if (_bookings.isEmpty) {
      return Center(
        child: Text('No bookings yet'),
      );
    }
    return ListView.builder(
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final Booking booking = _bookings[index];
          final items = booking.id == null
              ? const <BookingItem>[]
              : _bookingItems[booking.id!] ?? const <BookingItem>[];
          return Card(
            child: ListTile(
              title: Text('Booking #${booking.bookingNumber}'),
              subtitle: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (items.isEmpty)
                    Text('Summary: ${booking.summary}')
                  else
                    ...items.map(
                      (item) => Text(
                        '${item.quantity} x ${item.movieName} at '
                        '£${item.unitPrice.toStringAsFixed(2)} each '
                        '— £${item.lineTotal.toStringAsFixed(2)}',
                      ),
                    ),
                  Text('Date Booked: ${_formatBookingDate(booking.date)}'),
                  Text('Total: £${booking.total.toStringAsFixed(2)}'),
                ],
              ),
            ),
          );
        });
  }

  String _formatBookingDate(String storedDate) {
    final date = DateTime.tryParse(storedDate);

    if (date == null) {
      return storedDate;
    }

    final localDate = date.toLocal();

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${twoDigits(localDate.day)}/${twoDigits(localDate.month)}/'
        '${localDate.year} '
        '${twoDigits(localDate.hour)}:${twoDigits(localDate.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final BasketRepository basket = BasketRepository.instance;
    final List<BasketItem> items = basket.getItems();
    return Scaffold(
        appBar: AppBar(
          title: Text('My Basket'),
        ),
        drawer: NavDrawer(),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: items.isEmpty
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Your Basket is Empty'),
                          SizedBox(
                            height: 5,
                          ),
                          Text(_confirmationMessage),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemBuilder: (context, index) {
                                final BasketItem item = items[index];
                                return Card(
                                  child: ListTile(
                                    title: Text(item.movie.name),
                                    subtitle: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "${item.quantity} tickets at ${item.movie.formattedPrice} each"),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                            "£${item.lineTotal.toStringAsFixed(2)}")
                                      ],
                                    ),
                                    trailing: IconButton(
                                      key: ValueKey('remove-${item.movie.id}'),
                                      onPressed: () {
                                        setState(() {
                                          basket.removeItem(index);
                                        });
                                      },
                                      icon: Icon(Icons.delete_outline),
                                      tooltip: 'Remove tickets',
                                    ),
                                  ),
                                );
                              },
                              itemCount: items.length,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                              "Total Ticket Quantity: ${basket.getTotalItems()}"),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                              "Total £${basket.getTotalDue().toStringAsFixed(2)}"),
                          SizedBox(
                            height: 10,
                          ),
                          PrimaryButton(
                              label: 'Clear basket',
                              onPressed: () {
                                setState(() {
                                  basket.clear();
                                });
                              }),
                          PrimaryButton(
                            label: 'Checkout',
                            onPressed: _checkout,
                          ),
                          if (_confirmationMessage.isNotEmpty)
                            Text(_confirmationMessage),
                        ],
                      ),
              ),
            ),
            const Divider(),
            const Text('Past Bookings'),
            SizedBox(
              height: 220,
              child: _buildBookingHistory(),
            ),
          ],
        ));
  }
}
