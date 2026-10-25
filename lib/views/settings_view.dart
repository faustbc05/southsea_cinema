import 'package:flutter/material.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Settings'),
      ),
      drawer: NavDrawer(),
      body: Center(
        child: Text('settings'),
      ),
    );
  }
}
