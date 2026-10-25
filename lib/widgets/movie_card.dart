import 'package:flutter/material.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/views/movie_listing.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final screening = movie.screeningTime;

    final date = localizations.formatMediumDate(screening);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(screening),
      alwaysUse24HourFormat: true,
    );
    return Card(
      color: cinemaSurface,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 400;
              final posterWidth = isNarrow
                  ? (constraints.maxWidth * 0.5).clamp(80.0, 180.0).toDouble()
                  : 120.0;

              final poster = Image.asset(
                movie.imagePath,
                width: posterWidth,
                height: posterWidth * 1.5,
                fit: BoxFit.cover,
              );

              final details = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.name, style: cinemaHeaderStyle),
                    Text(movie.ageRating),
                    Text(movie.description),
                  ]);

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    poster,
                    const SizedBox(
                      height: 16,
                    ),
                    details,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  poster,
                  const SizedBox(width: 16),
                  Expanded(child: details),
                ],
              );
            }),
            SizedBox(
              height: 10,
            ),
            Text('$date at $time'),
            SizedBox(height: 10),
            PrimaryButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return MovieListing(movie: movie);
                      },
                    ),
                  );
                },
                label: 'Book Tickets'),
          ],
        ),
      ),
    );
  }
}
