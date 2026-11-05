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

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imagePath: json['imagePath'] as String,
      ticketPrice: (json['ticketPrice'] as num).toDouble(),
      ageRating: json['ageRating'] as String,
      screeningTime: DateTime.parse(json['screeningTime'] as String),
      runtimeMinutes: json['runtimeMinutes'] as int,
      location: json['location'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imagePath': imagePath,
      'ticketPrice': ticketPrice,
      'ageRating': ageRating,
      'screeningTime': screeningTime.toIso8601String(),
      'runtimeMinutes': runtimeMinutes,
      'location': location,
    };
  }

  String get formattedPrice {
    return '£${ticketPrice.toStringAsFixed(2)}';
  }
}
