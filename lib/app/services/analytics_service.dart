import 'package:first_vania_project/app/models/order.dart';
import 'package:first_vania_project/app/models/order_item.dart';
import 'package:first_vania_project/app/models/product.dart';
import 'package:first_vania_project/app/models/user.dart';

class AnalyticsService {
  /// Admin dashboard analitik verileri
  Future<Map<String, dynamic>> getDashboardAnalytics() async {
    final totalUsers = await _getTotalUsers();
    final totalOrders = await _getTotalOrders();
    final totalRevenue = await _getTotalRevenue();
    final totalProducts = await _getTotalProducts();
    final ordersByStatus = await _getOrdersByStatus();
    final popularProducts = await _getPopularProducts(limit: 10);
    final recentOrders = await _getRecentOrders(limit: 5);

    return {
      'summary': {
        'total_users': totalUsers,
        'total_orders': totalOrders,
        'total_revenue': totalRevenue,
        'total_products': totalProducts,
      },
      'orders_by_status': ordersByStatus,
      'popular_products': popularProducts,
      'recent_orders': recentOrders,
    };
  }

  Future<int> _getTotalUsers() async {
    final users = await User().query.get();
    return users.length;
  }

  Future<int> _getTotalOrders() async {
    final orders = await Order().query.get();
    return orders.length;
  }

  Future<double> _getTotalRevenue() async {
    final orders = await Order()
        .query
        .where('status', '!=', 'cancelled')
        .get();

    double total = 0;
    for (final order in orders) {
      total += (order['total_amount'] as num).toDouble();
    }
    return double.parse(total.toStringAsFixed(2));
  }

  Future<int> _getTotalProducts() async {
    final products = await Product().query.where('is_active', '=', true).get();
    return products.length;
  }

  Future<Map<String, int>> _getOrdersByStatus() async {
    final statuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
    final result = <String, int>{};

    for (final status in statuses) {
      final orders =
          await Order().query.where('status', '=', status).get();
      result[status] = orders.length;
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> _getPopularProducts(
      {int limit = 10}) async {
    // Sipariş kalemlerinden popüler ürünleri hesapla
    final allOrderItems = await OrderItem().query.get();

    final productSales = <int, int>{};
    final productRevenue = <int, double>{};

    for (final item in allOrderItems) {
      final productId = item['product_id'] as int;
      final qty = item['quantity'] as int;
      final totalPrice = (item['total_price'] as num).toDouble();

      productSales[productId] = (productSales[productId] ?? 0) + qty;
      productRevenue[productId] =
          (productRevenue[productId] ?? 0) + totalPrice;
    }

    // Satışa göre sırala
    final sortedProducts = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final result = <Map<String, dynamic>>[];
    for (final entry in sortedProducts.take(limit)) {
      final product =
          await Product().query.where('id', '=', entry.key).first();
      if (product != null) {
        result.add({
          'product_id': entry.key,
          'product_name': product['name'],
          'total_sold': entry.value,
          'total_revenue':
              double.parse((productRevenue[entry.key] ?? 0).toStringAsFixed(2)),
        });
      }
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> _getRecentOrders(
      {int limit = 5}) async {
    final orders = await Order()
        .query
        .orderBy('created_at', 'desc')
        .limit(limit)
        .get();

    final result = <Map<String, dynamic>>[];
    for (final order in orders) {
      final user = await User()
          .query
          .where('id', '=', order['user_id'])
          .first();

      result.add({
        'order_number': order['order_number'],
        'status': order['status'],
        'total_amount': order['total_amount'],
        'user_name': user?['name'],
        'user_email': user?['email'],
        'created_at': order['created_at']?.toString(),
      });
    }

    return result;
  }
}
