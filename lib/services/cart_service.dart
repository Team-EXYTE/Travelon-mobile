import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show debugPrint;
import '../data_model/event_model.dart';

class CartItem {
  final String id;
  final Event event;
  final int quantity;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.event,
    this.quantity = 1,
    required this.addedAt,
  });

  CartItem copyWith({
    String? id,
    Event? event,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      event: event ?? this.event,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  double get totalPrice {
    // Extract numeric value from price string by removing currency symbols and non-numeric characters
    String priceStr = event.price
        .replaceAll('Rs.', '')
        .replaceAll('\Rs.', '')
        .replaceAll('LKR', '')
        .replaceAll('\$', '')
        .trim();
    
    try {
      return double.parse(priceStr) * quantity;
    } catch (e) {
      debugPrint('Failed to parse price: ${event.price}, error: $e');
      return 0.0; // For events with non-numeric prices or "Free"
    }
  }
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.fold(0.0, (total, item) => total + item.totalPrice);
  }

  bool isInCart(String eventId) {
    return _items.any((item) => item.event.id == eventId);
  }

  void addToCart(Event event) {
    // Check if item already exists
    final existingIndex = _items.indexWhere(
      (item) => item.event.id == event.id,
    );

    if (existingIndex != -1) {
      // Update quantity if item exists
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + 1,
      );
    } else {
      // Add new item
      _items.add(
        CartItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          event: event,
          addedAt: DateTime.now(),
        ),
      );
    }
    notifyListeners();
  }

  void removeFromCart(String eventId) {
    _items.removeWhere((item) => item.event.id == eventId);
    notifyListeners();
  }

  void updateQuantity(String eventId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(eventId);
      return;
    }

    final index = _items.indexWhere((item) => item.event.id == eventId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(quantity: newQuantity);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  CartItem? getCartItem(String eventId) {
    try {
      return _items.firstWhere((item) => item.event.id == eventId);
    } catch (e) {
      return null;
    }
  }
}
