import 'package:southsea_cinema/models/movie.dart';

class MovieRepository {
  List<Movie> getMovies() {
    return [
      Movie(
        id: 'berserk',
        name: 'Berserk (1997)',
        description: 'A lone mercenary named Guts joins the Band of the Hawk, '
            'where friendship, ambition and betrayal shape his fate in a dark fantasy world.',
        imagePath: 'assets/images/berserk.jpg',
        ticketPrice: 4.99,
        ageRating: '18',
        screeningTime: DateTime(2026, 10, 20, 18, 30),
        runtimeMinutes: 90,
        location: 'Screen 1',
      ),
      Movie(
        id: 'steel-ball-run',
        name: "Steel Ball Run: JoJo's Bizarre Adventure (2026)",
        description: 'Johnny Joestar joins a race across America, '
            'where he encounters mysterious powers and dangerous rivals.',
        imagePath: 'assets/images/steel_ball_run.jpg',
        ticketPrice: 7.99,
        ageRating: '15',
        screeningTime: DateTime(2026, 10, 21, 19, 30),
        runtimeMinutes: 55,
        location: 'Screen 2',
      ),
    ];
  }
}
