import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/models/movie.dart';

class MovieListing extends StatefulWidget {
  final Movie movie;

  const MovieListing({
    super.key,
    required this.movie,
  });

  @override
  State<MovieListing> createState() => _MovieListingState();
}

class _MovieListingState extends State<MovieListing> {
  int _quantity = 0;
  String _feedback = "";
  int _basketCount = 0;
  final int _ticketLimit = 5;
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final filmDetails = Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "${widget.movie.name} ",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: cinemaBrandDark),
                        ),
                        TextSpan(text: "(${widget.movie.ageRating})"),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    widget.movie.description,
                  ),
                  SizedBox(height: 20),
                  Text(widget.movie.location),
                  SizedBox(height:4),
                  Text("Runtime: ${widget.movie.runtimeMinutes} minutes"),
                  SizedBox(height: 4),
                  Text(widget.movie.screeningTime.toString()),
                ],
              );

              final bookingControls = Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Please note that Discounts/Membership Benefits "
                      "will be applied once you have selected your tickets",
                      style: TextStyle(fontStyle: FontStyle.italic)),
                  SizedBox(height: 20),
                  Text("Tickets",
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.zero),
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
                      Text("Adult (£${widget.movie.ticketPrice.toStringAsFixed(2)})")
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
                  ),
                ],
              );

              if (constraints.maxWidth > 600) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: filmDetails),
                    SizedBox(width: 24),
                    Expanded(child: bookingControls),
                  ],
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  filmDetails,
                  SizedBox(height: 20),
                  bookingControls,
                ],
              );
            },
          ),
        ),
      ),
    );
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
