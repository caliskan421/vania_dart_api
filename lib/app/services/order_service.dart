import 'dart:math';
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
    // Sepeti getir
    final cart = await Cart().query.where('user_id', '=', userId).first();
    if (cart == null) {
      throw Exception('Cart is empty');
    }

    final cartItems = await CartItem().query.where('cart_id', '=', cart['id']).get();
    if (cartItems.isEmpty) {
      throw Exception('Cart is empty');
    }

    // Stok kontrolü ve toplam hesapla
    double subtotal = 0;
    final orderItemsData = <Map<String, dynamic>>[];

    for (final item in cartItems) {
      final product = await Product().query.where('id', '=', item['product_id']).first();

      if (product == null) {
        throw Exception('Product #${item['product_id']} not found');
      }

      if ((product['stock'] as int) < (item['quantity'] as int)) {
        throw Exception('Insufficient stock for ${product['name']}. Available: ${product['stock']}');
      }

      final unitPrice = (item['unit_price'] as num).toDouble();
      final qty = item['quantity'] as int;
      final totalPrice = unitPrice * qty;
      subtotal += totalPrice;

      orderItemsData.add({
        'product_id': item['product_id'],
        'product_name': product['name'],
        'quantity': qty,
        'unit_price': unitPrice,
        'total_price': double.parse(totalPrice.toStringAsFixed(2)),
      });
    }

    final taxAmount = double.parse((subtotal * taxRate).toStringAsFixed(2));
    final totalAmount = double.parse((subtotal + taxAmount + shippingCost).toStringAsFixed(2));
    final orderNumber = _generateOrderNumber();

    // Siparişi oluştur
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

    final order = await Order().query.where('order_number', '=', orderNumber).first();

    // Sipariş kalemlerini oluştur
    for (final itemData in orderItemsData) {
      await OrderItem().query.insert({
        'order_id': order!['id'],
        'product_id': itemData['product_id'],
        'product_name': itemData['product_name'],
        'quantity': itemData['quantity'],
        'unit_price': itemData['unit_price'],
        'total_price': itemData['total_price'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Stok azalt
      final product = await Product().query.where('id', '=', itemData['product_id']).first();
      if (product != null) {
        final newStock = (product['stock'] as int) - (itemData['quantity'] as int);
        await Product().query.where('id', '=', itemData['product_id']).update({
          'stock': newStock,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    }

    // Sepeti temizle
    await CartItem().query.where('cart_id', '=', cart['id']).delete();

    // E-posta gönder
    final user = await User().query.where('id', '=', userId).first();
    if (user != null) {
      await _emailService.sendOrderConfirmationEmail(user['email'].toString(), orderNumber, totalAmount);
    }

    return await getOrderById(order!['id'] as int, userId: userId) ?? {};
  }

  /// Kullanıcının siparişlerini getir
  Future<List<Map<String, dynamic>>> getUserOrders(int userId, {int page = 1, int perPage = 20}) async {
    final offset = (page - 1) * perPage;
    final orders = await Order().query.where('user_id', '=', userId).orderBy('created_at', 'desc').limit(perPage).offset(offset).get();

    final result = <Map<String, dynamic>>[];
    for (final order in orders) {
      final items = await OrderItem().query.where('order_id', '=', order['id']).get();
      result.add({
        ...order,
        'items': items,
      });
    }
    return result;
  }

  /// Sipariş detayı getir
  Future<Map<String, dynamic>?> getOrderById(int orderId, {int? userId}) async {
    var query = Order().query.where('id', '=', orderId);
    if (userId != null) {
      query = query.where('user_id', '=', userId);
    }
    final order = await query.first();
    if (order == null) return null;

    final items = await OrderItem().query.where('order_id', '=', orderId).get();

    return {
      ...order,
      'items': items,
    };
  }

  /// Tüm siparişleri getir (admin)
  Future<Map<String, dynamic>> getAllOrders({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    QueryBuilder query = Order().query;
    if (status != null && status.isNotEmpty) {
      query = query.where('status', '=', status);
    }

    final allOrders = await Order().query.get();
    final total = allOrders.length;

    final offset = (page - 1) * perPage;
    final orders = await query.orderBy('created_at', 'desc').limit(perPage).offset(offset).get();

    final result = <Map<String, dynamic>>[];
    for (final order in orders) {
      final items = await OrderItem().query.where('order_id', '=', order['id']).get();

      final user = await User().query.where('id', '=', order['user_id']).first();

      result.add({
        ...order,
        'items': items,
        'user': user != null
            ? {
                'id': user['id'],
                'name': user['name'],
                'email': user['email'],
              }
            : null,
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

    final order = await Order().query.where('id', '=', orderId).first();
    if (order == null) {
      throw Exception('Order not found');
    }

    // Durum geçiş kuralları
    final currentStatus = order['status'].toString();
    if (!_isValidTransition(currentStatus, status)) {
      throw Exception('Cannot transition from "$currentStatus" to "$status"');
    }

    await Order().query.where('id', '=', orderId).update({
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Kullanıcıya bilgi gönder
    final user = await User().query.where('id', '=', order['user_id']).first();
    if (user != null) {
      await _emailService.sendOrderStatusUpdateEmail(user['email'].toString(), order['order_number'].toString(), status);
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
