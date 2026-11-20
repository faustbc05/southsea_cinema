class BookingItem {
  final int? id;
  final int bookingId;
  final String movieId;
  final String movieName;
  final double unitPrice;
  final int quantity;

  const BookingItem({
    this.id,
    required this.bookingId,
    required this.movieId,
    required this.movieName,
    required this.unitPrice,
    required this.quantity,
  });

  double get lineTotal => unitPrice * quantity;

  Map<String, Object?> toMap() {
    final data = <String, Object?>{
      'booking_id': bookingId,
      'movie_id': movieId,
      'movie_name': movieName,
      'unit_price': unitPrice,
      'quantity': quantity,
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  factory BookingItem.fromMap(Map<String, Object?> map) {
    return BookingItem(
      id: map['id'] as int?,
      bookingId: map['booking_id'] as int,
      movieId: map['movie_id'] as String,
      movieName: map['movie_name'] as String,
      unitPrice: (map['unit_price'] as num).toDouble(),
      quantity: map['quantity'] as int,
    );
  }
}
