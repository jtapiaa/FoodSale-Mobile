import '../models/cart_item.dart';

class CartService {
  static final List<CartItem> _items = [];

  static List<CartItem> get items => _items;

  static int? restaurantId;

  static void addItem({
    required int productId,
    required String name,
    required int price,
  }) {
    final existingIndex = _items.indexWhere(
      (item) => item.productId == productId,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(
        CartItem(
          productId: productId,
          name: name,
          price: price,
        ),
      );
    }
  }

  static void removeItem(int productId) {
    _items.removeWhere(
      (item) => item.productId == productId,
    );
  }

  static void increaseQuantity(int productId) {
    final item = _items.firstWhere(
      (item) => item.productId == productId,
    );

    item.quantity++;
  }

  static void decreaseQuantity(int productId) {
    final item = _items.firstWhere(
      (item) => item.productId == productId,
    );

    if (item.quantity > 1) {
      item.quantity--;
    } else {
      removeItem(productId);
    }
  }

  static int get subtotal {
    return _items.fold(
      0,
      (sum, item) => sum + item.total,
    );
  }

  static int get itemCount {
    return _items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  static void clear() {
    _items.clear();
  }


}