import 'package:southsea_cinema/models/movie.dart';

class BasketItem {
  final Movie movie;
  final int quantity;

  const BasketItem({required this.movie, required this.quantity});

  double get lineTotal {
    double total = movie.ticketPrice * quantity;
    return total;
  }

  Map<String, dynamic> toJson() {
    return {"movie": movie.toJson(), "quantity": quantity};
  }

  factory BasketItem.fromJson(Map<String, dynamic> json) {
    return BasketItem(
        movie: Movie.fromJson(json['movie'] as Map<String, dynamic>),
        quantity: json['quantity'] as int);
  }
}
