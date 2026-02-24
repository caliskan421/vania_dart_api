import 'package:first_vania_project/app/dto/cart_dto.dart';
import 'package:first_vania_project/app/dto/cart_item_dto.dart';
import 'package:first_vania_project/app/models/cart.dart';
import 'package:first_vania_project/app/models/cart_item.dart';
import 'package:first_vania_project/app/models/product.dart';

class CartService {
  /// Sepete ürün ekle
  Future<Map<String, dynamic>> addItem(int userId, int productId, int quantity) async {
    final product = await Product().findById(productId);

    if (product == null) throw Exception('Product not found');
    if (!product.isActive) throw Exception('Product is not available');
    if (product.stock < quantity) {
      throw Exception('Insufficient stock. Available: ${product.stock}');
    }

    final cart = await getOrCreateCart(userId);

    final existingItemMap = await CartItem().query.where('cart_id', '=', cart.id).where('product_id', '=', productId).first();

    if (existingItemMap != null) {
      final existingItem = CartItemDto.fromMap(existingItemMap);
      final newQty = existingItem.quantity + quantity;
      if (product.stock < newQty) {
        throw Exception('Insufficient stock. Available: ${product.stock}');
      }
      await CartItem().query.where('id', '=', existingItem.id).update({
        'quantity': newQty,
        'unit_price': product.effectivePrice,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } else {
      await CartItem().query.insert({
        'cart_id': cart.id,
        'product_id': productId,
        'quantity': quantity,
        'unit_price': product.effectivePrice,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }

    return await getCartWithItems(userId);
  }

  /// Sepet öğesinin miktarını güncelle
  Future<Map<String, dynamic>> updateItemQuantity(int userId, int cartItemId, int quantity) async {
    final cart = await getOrCreateCart(userId);

    final itemMap = await CartItem().query.where('id', '=', cartItemId).where('cart_id', '=', cart.id).first();

    if (itemMap == null) {
      throw Exception('Cart item not found');
    }
    final item = CartItemDto.fromMap(itemMap);

    final product = await Product().findById(item.productId);
    if (product != null && product.stock < quantity) {
      throw Exception('Insufficient stock. Available: ${product.stock}');
    }

    await CartItem().query.where('id', '=', cartItemId).update({
      'quantity': quantity,
      'updated_at': DateTime.now().toIso8601String(),
    });

    return await getCartWithItems(userId);
  }

  /// Sepetten ürün çıkar
  Future<Map<String, dynamic>> removeItem(int userId, int cartItemId) async {
    final cart = await getOrCreateCart(userId);

    final itemMap = await CartItem().query.where('id', '=', cartItemId).where('cart_id', '=', cart.id).first();

    if (itemMap == null) {
      throw Exception('Cart item not found');
    }

    await CartItem().query.where('id', '=', cartItemId).delete();

    return await getCartWithItems(userId);
  }

  /// Sepeti temizle
  Future<void> clearCart(int userId) async {
    final cart = await getOrCreateCart(userId);
    await CartItem().query.where('cart_id', '=', cart.id).delete();
  }

  /// Kullanıcının sepetini getir (yoksa oluştur) — typed döner
  Future<CartDto> getOrCreateCart(int userId) async {
    var cart = await Cart().findByUserId(userId);

    if (cart == null) {
      await Cart().query.insert({
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      cart = await Cart().findByUserId(userId);
    }

    return cart!;
  }

  /// Sepet detayını getir (ürünlerle birlikte)
  Future<Map<String, dynamic>> getCartWithItems(int userId) async {
    final cart = await getOrCreateCart(userId);

    final cartItems = await CartItem().findByCartId(cart.id);

    double subtotal = 0;
    final enrichedItems = <Map<String, dynamic>>[];

    for (final item in cartItems) {
      final product = await Product().findById(item.productId);

      if (product != null) {
        subtotal += item.totalPrice;

        enrichedItems.add({
          'id': item.id,
          'product_id': item.productId,
          'product_name': product.name,
          'product_image': null,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'total_price': item.totalPrice,
          'stock_available': product.stock,
        });
      }
    }

    final taxRate = 0.18;
    final taxAmount = subtotal * taxRate;
    final total = subtotal + taxAmount;

    return {
      'cart_id': cart.id,
      'items': enrichedItems,
      'item_count': enrichedItems.length,
      'subtotal': double.parse(subtotal.toStringAsFixed(2)),
      'tax_rate': taxRate,
      'tax_amount': double.parse(taxAmount.toStringAsFixed(2)),
      'total': double.parse(total.toStringAsFixed(2)),
    };
  }
}
