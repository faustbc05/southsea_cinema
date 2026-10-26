import 'package:flutter/material.dart';
import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

class BasketView extends StatefulWidget {
  const BasketView({super.key});

  @override
  State<BasketView> createState() => _BasketViewState();
}

class _BasketViewState extends State<BasketView> {
  String _confirmationMessage = '';
  @override
  Widget build(BuildContext context) {
    final BasketRepository basket = BasketRepository.instance;
    final List<BasketItem> items = basket.getItems();
    return Scaffold(
        appBar: AppBar(
          title: Text('My Basket'),
        ),
        drawer: NavDrawer(),
        body: Center(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${item.quantity} tickets at ${item.movie.formattedPrice} each"),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text("£${item.lineTotal.toStringAsFixed(2)}")
                                ],
                              ),
                              trailing: IconButton(
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
                    Text("Total Ticket Quantity: ${basket.getTotalItems()}"),
                    SizedBox(
                      height: 2,
                    ),
                    Text("Total £${basket.getTotalDue().toStringAsFixed(2)}"),
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
                        onPressed: () {
                          setState(() {
                            basket.clear();
                            _confirmationMessage = 'Checkout Successful!';
                          });
                        }),
                  ],
                ),
        ));
  }
}
