import 'package:flutter/material.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

class BasketView extends StatelessWidget {
  const BasketView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Basket'),
      ),
      drawer: NavDrawer(),
      body: Center(
        child: Text('basket'),
      ),
    );
  }
}
