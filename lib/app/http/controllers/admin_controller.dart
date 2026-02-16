import 'package:first_vania_project/app/http/requests/order/update_order_status_request.dart';
import 'package:first_vania_project/app/services/analytics_service.dart';
import 'package:first_vania_project/app/services/order_service.dart';
import 'package:first_vania_project/app/services/user_service.dart';
import 'package:vania/http/controller.dart';
import 'package:vania/http/request.dart';
import 'package:vania/http/response.dart';
import 'package:vania/vania.dart';

class AdminController extends Controller {
  final UserService _userService = UserService();
  final OrderService _orderService = OrderService();
  final AnalyticsService _analyticsService = AnalyticsService();

  // ===== KULLANICI YÖNETİMİ =====

  /// GET /api/v1/admin/users
  Future<Response> listUsers(Request request) async {
    try {
      final page = int.tryParse(request.input('page')?.toString() ?? '1') ?? 1;
      final perPage = int.tryParse(request.input('per_page')?.toString() ?? '20') ?? 20;

      final users = await _userService.getAllUsers(page: page, perPage: perPage);
      final totalUsers = await _userService.getUserCount();

      return Response.json({
        'success': true,
        'data': users,
        'pagination': {
          'current_page': page,
          'per_page': perPage,
          'total': totalUsers,
          'last_page': (totalUsers / perPage).ceil(),
        },
      }, 200);
    } catch (e) {
      return Response.json({
        'success': false,
        'message': 'Failed to fetch users',
      }, 500);
    }
  }

  /// GET /api/v1/admin/users/{id}
  Future<Response> showUser(Request request, dynamic id) async {
    try {
      final userId = int.parse(id.toString());
      final user = await _userService.getUserById(userId);

      if (user == null) {
        return Response.json({
          'success': false,
          'message': 'User not found',
        }, 404);
      }

      return Response.json({
        'success': true,
        'data': user,
      }, 200);
    } catch (e) {
      return Response.json({
        'success': false,
        'message': 'Failed to fetch user',
      }, 500);
    }
  }

  /// DELETE /api/v1/admin/users/{id}
  Future<Response> deleteUser(Request request, dynamic id) async {
    try {
      final userId = int.parse(id.toString());
      await _userService.deleteUser(userId);

      return Response.json({
        'success': true,
        'message': 'User deleted successfully',
      }, 200);
    } on Exception catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      return Response.json({
        'success': false,
        'message': message,
      }, 400);
    }
  }

  // ===== SİPARİŞ YÖNETİMİ =====

  /// GET /api/v1/admin/orders
  Future<Response> listOrders(Request request) async {
    try {
      final status = request.input('status')?.toString();
      final page = int.tryParse(request.input('page')?.toString() ?? '1') ?? 1;
      final perPage = int.tryParse(request.input('per_page')?.toString() ?? '20') ?? 20;

      final result = await _orderService.getAllOrders(
        status: status,
        page: page,
        perPage: perPage,
      );

      return Response.json({
        'success': true,
        'data': result['orders'],
        'pagination': result['pagination'],
      }, 200);
    } catch (e) {
      return Response.json({
        'success': false,
        'message': 'Failed to fetch orders',
      }, 500);
    }
  }

  /// PUT /api/v1/admin/orders/{id}/status
  Future<Response> updateOrderStatus(Request request, dynamic id) async {
    try {
      await UpdateOrderStatusRequest().validate(request);
    } on ValidationException catch (e) {
      return Response.json({
        'success': false,
        'message': 'Validation failed',
        'errors': e.message,
      }, 422);
    }

    try {
      final orderId = int.parse(id.toString());
      final status = request.input('status').toString();

      final order = await _orderService.updateOrderStatus(orderId, status);

      return Response.json({
        'success': true,
        'message': 'Order status updated successfully',
        'data': order,
      }, 200);
    } on Exception catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      return Response.json({
        'success': false,
        'message': message,
      }, 400);
    }
  }

  // ===== ANALİTİK =====

  /// GET /api/v1/admin/analytics
  Future<Response> analytics(Request request) async {
    try {
      final data = await _analyticsService.getDashboardAnalytics();

      return Response.json({
        'success': true,
        'data': data,
      }, 200);
    } catch (e) {
      return Response.json({
        'success': false,
        'message': 'Failed to fetch analytics',
      }, 500);
    }
  }
}
