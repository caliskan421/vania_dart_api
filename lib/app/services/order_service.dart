import 'dart:math';
import 'package:first_vania_project/app/dto/order_dto.dart';
import 'package:first_vania_project/app/models/cart.dart';
import 'package:first_vania_project/app/models/cart_item.dart';
import 'package:first_vania_project/app/models/order.dart';
import 'package:first_vania_project/app/models/order_item.dart';
import 'package:first_vania_project/app/models/product.dart';
import 'package:first_vania_project/app/models/user.dart';
import 'package:first_vania_project/app/services/email_service.dart';
import 'package:vania/query_builder.dart';

class OrderService {
  final EmailService _emailService = EmailService();

  static const List<String> validStatuses = [
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];

  static const double taxRate = 0.18;
  static const double shippingCost = 29.90;

  /// Sepetten sipariş oluştur
  Future<Map<String, dynamic>> createOrderFromCart(int userId, Map<String, dynamic> shippingData) async {
    final cart = await Cart().findByUserId(userId);
    if (cart == null) {
      throw Exception('Cart is empty');
    }

    final cartItems = await CartItem().findByCartId(cart.id);
    if (cartItems.isEmpty) {
      throw Exception('Cart is empty');
    }

    double subtotal = 0;
    final orderItemsData = <Map<String, dynamic>>[];

    for (final item in cartItems) {
      final product = await Product().findById(item.productId);

      if (product == null) {
        throw Exception('Product #${item.productId} not found');
      }

      if (product.stock < item.quantity) {
        throw Exception('Insufficient stock for ${product.name}. Available: ${product.stock}');
      }

      final totalPrice = item.unitPrice * item.quantity;
      subtotal += totalPrice;

      orderItemsData.add({
        'product_id': item.productId,
        'product_name': product.name,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
        'total_price': double.parse(totalPrice.toStringAsFixed(2)),
      });
    }

    final taxAmount = double.parse((subtotal * taxRate).toStringAsFixed(2));
    final totalAmount = double.parse((subtotal + taxAmount + shippingCost).toStringAsFixed(2));
    final orderNumber = _generateOrderNumber();

    await Order().query.insert({
      'user_id': userId,
      'order_number': orderNumber,
      'status': 'pending',
      'subtotal': double.parse(subtotal.toStringAsFixed(2)),
      'tax_amount': taxAmount,
      'shipping_cost': shippingCost,
      'total_amount': totalAmount,
      'shipping_address': shippingData['shipping_address'],
      'shipping_city': shippingData['shipping_city'],
      'shipping_phone': shippingData['shipping_phone'],
      'notes': shippingData['notes'],
      'invoice_path': null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    final order = await Order().findByOrderNumber(orderNumber);

    for (final itemData in orderItemsData) {
      await OrderItem().query.insert({
        'order_id': order!.id,
        'product_id': itemData['product_id'],
        'product_name': itemData['product_name'],
        'quantity': itemData['quantity'],
        'unit_price': itemData['unit_price'],
        'total_price': itemData['total_price'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      final product = await Product().findById(itemData['product_id'] as int);
      if (product != null) {
        final newStock = product.stock - (itemData['quantity'] as int);
        await Product().query.where('id', '=', product.id).update({
          'stock': newStock,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    }

    // Sepeti temizle
    await CartItem().query.where('cart_id', '=', cart.id).delete();

    // E-posta gönder
    final user = await User().findById(userId);
    if (user != null) {
      await _emailService.sendOrderConfirmationEmail(user.email, orderNumber, totalAmount);
    }

    return await getOrderById(order!.id, userId: userId) ?? {};
  }

  /// Kullanıcının siparişlerini getir
  Future<List<Map<String, dynamic>>> getUserOrders(int userId, {int page = 1, int perPage = 20}) async {
    final offset = (page - 1) * perPage;
    final orderMaps = await Order().query.where('user_id', '=', userId).orderBy('created_at', 'desc').limit(perPage).offset(offset).get();

    final result = <Map<String, dynamic>>[];
    for (final orderMap in orderMaps) {
      final order = OrderDto.fromMap(orderMap);
      final items = await OrderItem().query.where('order_id', '=', order.id).get();
      result.add({
        ...orderMap,
        'items': items,
      });
    }
    return result;
  }

  /// Sipariş detayı getir
  Future<Map<String, dynamic>?> getOrderById(int orderId, {int? userId}) async {
    var q = Order().query.where('id', '=', orderId);
    if (userId != null) {
      q = q.where('user_id', '=', userId);
    }
    final orderMap = await q.first();
    if (orderMap == null) return null;

    final order = OrderDto.fromMap(orderMap);
    final items = await OrderItem().query.where('order_id', '=', order.id).get();

    return {
      ...orderMap,
      'items': items,
    };
  }

  /// Tüm siparişleri getir (admin)
  Future<Map<String, dynamic>> getAllOrders({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    QueryBuilder q = Order().query;
    if (status != null && status.isNotEmpty) {
      q = q.where('status', '=', status);
    }

    final allOrders = await Order().query.get();
    final total = allOrders.length;

    final offset = (page - 1) * perPage;
    final orderMaps = await q.orderBy('created_at', 'desc').limit(perPage).offset(offset).get();

    final result = <Map<String, dynamic>>[];
    for (final orderMap in orderMaps) {
      final order = OrderDto.fromMap(orderMap);
      final items = await OrderItem().query.where('order_id', '=', order.id).get();

      final user = await User().findById(order.userId);

      result.add({
        ...orderMap,
        'items': items,
        'user': user != null ? {'id': user.id, 'name': user.name, 'email': user.email} : null,
      });
    }

    return {
      'orders': result,
      'pagination': {
        'current_page': page,
        'per_page': perPage,
        'total': total,
        'last_page': (total / perPage).ceil(),
      },
    };
  }

  /// Sipariş durumunu güncelle (admin)
  Future<Map<String, dynamic>> updateOrderStatus(int orderId, String status) async {
    if (!validStatuses.contains(status)) {
      throw Exception('Invalid status. Valid statuses: ${validStatuses.join(', ')}');
    }

    final order = await Order().findById(orderId);
    if (order == null) {
      throw Exception('Order not found');
    }

    if (!_isValidTransition(order.status, status)) {
      throw Exception('Cannot transition from "${order.status}" to "$status"');
    }

    await Order().query.where('id', '=', orderId).update({
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    });

    final user = await User().findById(order.userId);
    if (user != null) {
      await _emailService.sendOrderStatusUpdateEmail(user.email, order.orderNumber, status);
    }

    return (await getOrderById(orderId))!;
  }

  /// Sipariş faturası yolunu güncelle
  Future<void> updateInvoicePath(int orderId, String path) async {
    await Order().query.where('id', '=', orderId).update({
      'invoice_path': path,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Durum geçiş kuralları
  bool _isValidTransition(String from, String to) {
    final transitions = {
      'pending': ['processing', 'cancelled'],
      'processing': ['shipped', 'cancelled'],
      'shipped': ['delivered'],
      'delivered': <String>[],
      'cancelled': <String>[],
    };
    return transitions[from]?.contains(to) ?? false;
  }

  /// Benzersiz sipariş numarası oluştur
  String _generateOrderNumber() {
    final now = DateTime.now();
    final random = Random.secure();
    final randomPart = List.generate(6, (_) => random.nextInt(10)).join();
    return 'ORD-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$randomPart';
  }
}
