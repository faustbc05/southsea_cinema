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
        color: Colors.red,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("STEEL BALL RUN: JOJO'S BIZARRE ADVENTURE (2026) (15)"),
            Text(
              'Johnny Joestar joins a race across America, '
              'where he encounters mysterious powers and dangerous rivals.',
            ),
            SizedBox(height: 20),
            Text("Southsea Cinema Room"),
            SizedBox(height: 4),
            Text("Friday 25 Sep 2026, 09:00 - Ends at 10:20"),
            SizedBox(height: 20),
            Text("Please note that Discounts/Membership Benefits "
                "will be applied once you have selected your tickets"),
            SizedBox(height: 20),
            Text("Tickets"),
            SizedBox(height: 4),
            Text("Max Quantity: 5"),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownMenu<int>(
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
            SizedBox(
              width: 200,
              height: 30,
              child: Placeholder(),
            ) //add to order button
          ],
        ),
      ),
    );
  }
}
