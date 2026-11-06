import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/user_settings.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String prefName = 'user_name';
const String prefAddress = 'user_address';
const String prefEmail = 'user_email';
const String prefNewsletter = 'user_newsletter';

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
    _loadSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();

    final String? savedName = await prefs.getString(prefName);
    final String? savedAddress = await prefs.getString(prefAddress);
    final String? savedEmail = await prefs.getString(prefEmail);
    final bool? savedNewsletter = await prefs.getBool(prefNewsletter);

    String name = '';
    String address = '';
    String email = '';
    bool newsletter = false;
    if (savedName != null) {
      name = savedName;
    }
    if (savedAddress != null) {
      address = savedAddress;
    }
    if (savedEmail != null) {
      email = savedEmail;
    }
    if (savedNewsletter != null) {
      newsletter = savedNewsletter;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _nameController.text = name;
      _addressController.text = address;
      _emailController.text = email;
      _receiveNewsletter = newsletter;
    });
  }

  Future<void> _saveSettings() async {
    final String name = _nameController.text.trim();
    final String address = _addressController.text.trim();
    final String email = _emailController.text.trim();

    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    await prefs.setString(prefName, name);
    await prefs.setString(prefAddress, address);
    await prefs.setString(prefEmail, email);
    await prefs.setBool(prefNewsletter, _receiveNewsletter);

    final UserSettings settings = UserSettings(
        name: name,
        address: address,
        email: email,
        receiveNewsletter: _receiveNewsletter);

    if (!mounted) {
      return;
    }
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
                title: Text(
                  'Sign up to the Newsletter?',
                  style: TextStyle(color: cinemaFontWhite),
                ),
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
