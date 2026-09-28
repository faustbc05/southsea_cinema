import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

class MovieListing extends StatelessWidget {
  const MovieListing({super.key});

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
        child: const Column(
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
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  height: 48,
                  child: Placeholder(),
                ), //quantity dropdown placeholder
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
