import 'package:southsea_cinema/models/basket_item.dart';

class BasketRepository {
  static final BasketRepository instance = BasketRepository._internal();
  final List<BasketItem> _items = [];

  BasketRepository._internal();

  List<BasketItem> getItems() {
    return List<BasketItem>.unmodifiable(_items);
  }

  void addItem(BasketItem item) {
    _items.add(item);
  }

  void clear() {
    _items.clear();
  }

  void removeItem(int index) {
    if (index >= 0 && index <= _items.length - 1) {
      _items.removeAt(index);
    }
  }

  int getTotalItems() {
    int total = 0;
    for (BasketItem item in _items) {
      total += item.quantity;
    }
    return total;
  }

  double getTotalDue() {
    double total = 0;
    for (BasketItem item in _items) {
      total += item.lineTotal;
    }
    return total;
  }
}
