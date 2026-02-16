import 'package:first_vania_project/app/models/cart.dart';
import 'package:first_vania_project/app/models/cart_item.dart';
import 'package:first_vania_project/app/models/product.dart';

class CartService {
  bool _isProductActive(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value == 1;
    final normalized = value.toString().trim().toLowerCase();
    return normalized == '1' || normalized == 'true';
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  /// Kullanıcının sepetini getir (yoksa oluştur)
  Future<Map<String, dynamic>> getOrCreateCart(int userId) async {
    var cart = await Cart().query.where('user_id', '=', userId).first();

    if (cart == null) {
      await Cart().query.insert({
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      cart = await Cart().query.where('user_id', '=', userId).first();
    }

    return cart!;
  }

  /// Sepet detayını getir (ürünlerle birlikte)
  Future<Map<String, dynamic>> getCartWithItems(int userId) async {
    final cart = await getOrCreateCart(userId);
    final cartId = cart['id'];

    final items = await CartItem()
        .query
        .where('cart_id', '=', cartId)
        .get();

    double subtotal = 0;
    final enrichedItems = <Map<String, dynamic>>[];

    for (final item in items) {
      final product = await Product()
          .query
          .where('id', '=', item['product_id'])
          .first();

      if (product != null) {
        final itemTotal =
            (item['unit_price'] as num).toDouble() * (item['quantity'] as int);
        subtotal += itemTotal;

        enrichedItems.add({
          'id': item['id'],
          'product_id': item['product_id'],
          'product_name': product['name'],
          'product_image': null,
          'quantity': item['quantity'],
          'unit_price': item['unit_price'],
          'total_price': itemTotal,
          'stock_available': product['stock'],
        });
      }
    }

    final taxRate = 0.18; // %18 KDV
    final taxAmount = subtotal * taxRate;
    final total = subtotal + taxAmount;

    return {
      'cart_id': cartId,
      'items': enrichedItems,
      'item_count': enrichedItems.length,
      'subtotal': double.parse(subtotal.toStringAsFixed(2)),
      'tax_rate': taxRate,
      'tax_amount': double.parse(taxAmount.toStringAsFixed(2)),
      'total': double.parse(total.toStringAsFixed(2)),
    };
  }

  /// Sepete ürün ekle
  Future<Map<String, dynamic>> addItem(
      int userId, int productId, int quantity) async {
    // Ürün kontrolü
    final product =
        await Product().query.where('id', '=', productId).first();
    if (product == null) {
      throw Exception('Product not found');
    }
    if (!_isProductActive(product['is_active'])) {
      throw Exception('Product is not available');
    }
    final stock = _toInt(product['stock']);
    if (stock < quantity) {
      throw Exception('Insufficient stock. Available: ${product['stock']}');
    }

    final cart = await getOrCreateCart(userId);
    final cartId = cart['id'];

    // Sepette zaten var mı kontrol et
    final existingItem = await CartItem()
        .query
        .where('cart_id', '=', cartId)
        .where('product_id', '=', productId)
        .first();

    final effectivePrice = product['discount_price'] != null
        ? (product['discount_price'] as num).toDouble()
        : (product['price'] as num).toDouble();

    if (existingItem != null) {
      // Miktarı güncelle
      final newQuantity = _toInt(existingItem['quantity']) + quantity;
      if (stock < newQuantity) {
        throw Exception(
            'Insufficient stock. Available: ${product['stock']}');
      }
      await CartItem()
          .query
          .where('id', '=', existingItem['id'])
          .update({
        'quantity': newQuantity,
        'unit_price': effectivePrice,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } else {
      // Yeni ürün ekle
      await CartItem().query.insert({
        'cart_id': cartId,
        'product_id': productId,
        'quantity': quantity,
        'unit_price': effectivePrice,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }

    return await getCartWithItems(userId);
  }

  /// Sepet öğesinin miktarını güncelle
  Future<Map<String, dynamic>> updateItemQuantity(
      int userId, int cartItemId, int quantity) async {
    final cart = await getOrCreateCart(userId);
    final cartId = cart['id'];

    final item = await CartItem()
        .query
        .where('id', '=', cartItemId)
        .where('cart_id', '=', cartId)
        .first();

    if (item == null) {
      throw Exception('Cart item not found');
    }

    // Stok kontrolü
    final product =
        await Product().query.where('id', '=', item['product_id']).first();
    if (product != null && _toInt(product['stock']) < quantity) {
      throw Exception(
          'Insufficient stock. Available: ${product['stock']}');
    }

    await CartItem()
        .query
        .where('id', '=', cartItemId)
        .update({
      'quantity': quantity,
      'updated_at': DateTime.now().toIso8601String(),
    });

    return await getCartWithItems(userId);
  }

  /// Sepetten ürün çıkar
  Future<Map<String, dynamic>> removeItem(int userId, int cartItemId) async {
    final cart = await getOrCreateCart(userId);
    final cartId = cart['id'];

    final item = await CartItem()
        .query
        .where('id', '=', cartItemId)
        .where('cart_id', '=', cartId)
        .first();

    if (item == null) {
      throw Exception('Cart item not found');
    }

    await CartItem().query.where('id', '=', cartItemId).delete();

    return await getCartWithItems(userId);
  }

  /// Sepeti temizle
  Future<void> clearCart(int userId) async {
    final cart = await getOrCreateCart(userId);
    final cartId = cart['id'];
    await CartItem().query.where('cart_id', '=', cartId).delete();
  }

  /// Sepetteki ürün sayısı
  Future<int> getCartItemCount(int userId) async {
    final cart =
        await Cart().query.where('user_id', '=', userId).first();
    if (cart == null) return 0;
    final items =
        await CartItem().query.where('cart_id', '=', cart['id']).get();
    return items.length;
  }
}
