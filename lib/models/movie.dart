class Movie {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final double ticketPrice;
  final String ageRating;
  final DateTime screeningTime;
  final int runtimeMinutes;
  final String location;

  const Movie({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.ticketPrice,
    required this.ageRating,
    required this.screeningTime,
    required this.runtimeMinutes,
    required this.location,
  });

  String get formattedPrice {
    return '£${ticketPrice.toStringAsFixed(2)}';
  }
}
