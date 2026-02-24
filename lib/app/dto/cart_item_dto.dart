// GENERATED — dart run tool/generate_dto.dart
// Bu dosya otomatik üretilmiştir. Elle düzenleme yapılabilir,
// ancak --force ile yeniden üretildiğinde değişiklikler kaybolur.

class CartItemDto {
  final int id;
  final int cartId;
  final int productId;
  final int quantity;
  final double unitPrice;

  const CartItemDto({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  factory CartItemDto.fromMap(Map<String, dynamic> map) {
    return CartItemDto(
      id: _parseInt(map['id']),
      cartId: _parseInt(map['cart_id']),
      productId: _parseInt(map['product_id']),
      quantity: _parseInt(map['quantity']),
      unitPrice: _parseDouble(map['unit_price']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cart_id': cartId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  /// Kalem toplam tutarı
  double get totalPrice => unitPrice * quantity;

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
