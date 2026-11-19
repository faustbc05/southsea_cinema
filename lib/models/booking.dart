import 'package:southsea_cinema/models/basket_item.dart';
import 'dart:convert';

class Booking {
  final String id;
  final List<BasketItem> items;
  final DateTime bookedAt;

  Booking({required this.id, required this.items, required this.bookedAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookedAt': bookedAt.toIso8601String(),
      'items': jsonEncode(items.map((item) => item.toJson()).toList()),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    final decodedItems = jsonDecode(map['items'] as String) as List<dynamic>;

    return Booking(
      id: map['id'] as String,
      items: decodedItems
          .map((item) => BasketItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      bookedAt: DateTime.parse(map['bookedAt'] as String),
    );
  }
}
