import 'package:flutter/material.dart';
import 'package:southsea_cinema/models/user_settings.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  bool _receiveNewsletter = false;
  String _confirmationMessage = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final String name = _nameController.text.trim();
    final String address = _addressController.text.trim();
    final String email = _emailController.text.trim();

    final UserSettings settings = UserSettings(
        name: name,
        address: address,
        email: email,
        receiveNewsletter: _receiveNewsletter);

    setState(() {
      _confirmationMessage = "${settings.name}, your settings have been saved";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Settings'),
      ),
      drawer: NavDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("User Profile"),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                  label: Text("Full name"), border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 5,
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                  label: Text("Address"), border: OutlineInputBorder()),
              maxLines: 3,
            ),
            SizedBox(
              height: 5,
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                  label: Text("Email"), border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(
              height: 5,
            ),
            SwitchListTile(
                title: Text('Sign up to the Newsletter?'),
                value: _receiveNewsletter,
                onChanged: (bool receive) {
                  setState(() {
                    _receiveNewsletter = receive;
                  });
                }),
            PrimaryButton(label: 'Save Settings', onPressed: _saveSettings),
            SizedBox(
              height: 5,
            ),
            Text(_confirmationMessage)
          ],
        ),
      ),
    );
  }
}
