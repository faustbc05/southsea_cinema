import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

class MovieListing extends StatefulWidget {
  const MovieListing({super.key});

  @override
  State<MovieListing> createState() => _MovieListingState();
}

class _MovieListingState extends State<MovieListing> {
  int _quantity = 0;
  String _feedback = "";
  int _basketCount = 0;
  int _ticketLimit = 5;
  bool _redText = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(appTitle, style: cinemaHeaderStyle),
          backgroundColor: cinemaSurface,
          iconTheme: const IconThemeData(color: cinemaBrand),
          elevation: 0,
        ),
        drawer: const NavDrawer(),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: cinemaFontWhite, fontSize: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "STEEL BALL RUN: JOJO'S BIZZARE ADVENTURE (2026) ",
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: cinemaBrandDark),
                      ),
                      TextSpan(text: "(15)"),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Johnny Joestar joins a race across America, '
                  'where he encounters mysterious powers and dangerous rivals.',
                ),
                SizedBox(height: 20),
                Text("Southsea Cinema Room"),
                SizedBox(height: 4),
                Text("Friday 25 Sep 2026, 09:00 - Ends at 10:20"),
                SizedBox(height: 20),
                Text(
                    "Please note that Discounts/Membership Benefits "
                    "will be applied once you have selected your tickets",
                    style: TextStyle(fontStyle: FontStyle.italic)),
                SizedBox(height: 20),
                Text("Tickets", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Max Quantity: $_ticketLimit"),
                SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownMenu<int>(
                      inputDecorationTheme: InputDecorationTheme(
                        filled: true,
                        fillColor: cinemaFontWhite,
                        border:
                            OutlineInputBorder(borderRadius: BorderRadius.zero),
                      ),
                      textStyle: TextStyle(color: Colors.black),
                      initialSelection: 0,
                      onSelected: (int? value) {
                        if (value != null) {
                          setState(() {
                            _quantity = value;
                          });
                        }
                      },
                      dropdownMenuEntries: [
                        DropdownMenuEntry(value: 0, label: "0"),
                        DropdownMenuEntry(value: 1, label: "1"),
                        DropdownMenuEntry(value: 2, label: "2"),
                        DropdownMenuEntry(value: 3, label: "3"),
                        DropdownMenuEntry(value: 4, label: "4"),
                        DropdownMenuEntry(value: 5, label: "5")
                      ],
                    ),
                    SizedBox(width: 10),
                    Text("Adult (£7.50)")
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                    onPressed: _addToOrder,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: cinemaBrand,
                        foregroundColor: cinemaFontWhite,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero)),
                    child: const Text("ADD TO ORDER")),
                SizedBox(height: 5),
                Text(
                  _feedback,
                  style: TextStyle(
                    color: _redText ? Colors.red : null,
                    fontWeight: _redText ? FontWeight.bold : null,
                  ),
                )
              ],
            ),
          ),
        ));
  }

  void _addToOrder() {
    if (_quantity != 0 && _basketCount + _quantity <= _ticketLimit) {
      _basketCount += _quantity;
      setState(() {
        _feedback = "$_quantity ticket(s) added to your order";
        _redText = false;
      });
    } else if (_quantity != 0 && _basketCount >= _ticketLimit) {
      setState(() {
        _feedback = "maximum tickets reached";
        _redText = true;
      });
    } else if (_quantity == 0 && _basketCount < _ticketLimit) {
      setState(() {
        _feedback = "please select a ticket quantity to add";
        _redText = false;
      });
    } else if (_basketCount + _quantity > _ticketLimit) {
      setState(() {
        _feedback = "this would exceed the ticket maximum";
        _redText = true;
      });
    } else {
      setState(() => _feedback = "");
    }
  }
}
