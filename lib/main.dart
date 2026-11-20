import 'package:material_ui/material_ui.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:southsea_cinema/views/settings_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:southsea_cinema/views/movie_listing.dart';

void main() {
  runApp(const SouthseaCinemaApp());
}

class SouthseaCinemaApp extends StatefulWidget {
  final String initialRoute;

  const SouthseaCinemaApp({
    super.key,
    this.initialRoute = '/',
  });

  @override
  State<SouthseaCinemaApp> createState() => _SouthseaCinemaAppState();
}

class _SouthseaCinemaAppState extends State<SouthseaCinemaApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    final String? savedThemeMode = await prefs.getString(prefThemeMode);
    final ThemeMode themeMode =
        savedThemeMode == 'light' ? ThemeMode.light : ThemeMode.dark;
    if (!mounted) {
      return;
    }
    setState(() {
      _themeMode = themeMode;
    });
  }

  Future<void> _setThemeMode(ThemeMode themeMode) async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    await prefs.setString(
      prefThemeMode,
      themeMode == ThemeMode.light ? 'light' : 'dark',
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFFF7F9FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: cinemaBrand,
          brightness: Brightness.light,
          primary: cinemaBrandDark,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          iconTheme: IconThemeData(color: cinemaBrandDark),
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: cinemaSurface,
          iconTheme: IconThemeData(color: cinemaBrand),
          titleTextStyle: cinemaHeaderStyle,
          elevation: 0,
        ),
        scaffoldBackgroundColor: cinemaBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: cinemaBrand,
          brightness: Brightness.dark,
          primary: cinemaBrand,
          surface: cinemaSurface,
        ),
      ),
      themeMode: _themeMode,
      initialRoute: widget.initialRoute,
      routes: {
        '/': (context) => const HomeView(),
        '/basket': (context) => const BasketView(),
        '/settings': (context) => SettingsView(
              themeMode: _themeMode,
              onThemeModeChanged: _setThemeMode,
            ),
        // '/listing': (context) => const MovieListing(),
      },
    );
  }
}
