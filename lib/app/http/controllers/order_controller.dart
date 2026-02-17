import 'package:first_vania_project/app/http/requests/order/create_order_request.dart';
import 'package:first_vania_project/app/services/order_service.dart';
import 'package:first_vania_project/app/services/file_upload_service.dart';
import 'package:vania/authentication.dart';
import 'package:vania/http/controller.dart';
import 'package:vania/http/request.dart';
import 'package:vania/http/response.dart';
import 'package:vania/src/exception/invalid_argument_exception.dart';
import 'package:vania/vania.dart';

class OrderController extends Controller {
  final OrderService _service = OrderService();
  final FileUploadService _fileService = FileUploadService();

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  int? _authUserId() => _toInt(Auth().user()['id']);

  /// POST /api/v1/orders
  Future<Response> store(Request request) async {
    try {
      await CreateOrderRequest().validate(request);
    } on ValidationException catch (e) {
      return Response.json({
        'success': false,
        'message': 'Validation failed',
        'errors': e.message,
      }, 422);
    }

    try {
      final userId = _authUserId();
      if (userId == null) {
        return Response.json({
          'success': false,
          'message': 'Authentication required',
        }, 401);
      }

      final order = await _service.createOrderFromCart(
        userId,
        {
          'shipping_address': request.input('shipping_address'),
          'shipping_city': request.input('shipping_city'),
          'shipping_phone': request.input('shipping_phone'),
          'notes': request.input('notes'),
        },
      );

      // Fatura oluştur (simüle)
      if (order['order_number'] != null) {
        final orderId = _toInt(order['id']);
        if (orderId == null) {
          throw Exception('Invalid order id');
        }
        final invoicePath = await _fileService.generateInvoice(
          orderId,
          order['order_number'].toString(),
        );
        await _service.updateInvoicePath(orderId, invoicePath);
        order['invoice_path'] = invoicePath;
      }

      return Response.json({
        'success': true,
        'message': 'Order created successfully',
        'data': order,
      }, 201);
    } on InvalidArgumentException catch (e) {
      return Response.json({
        'success': false,
        'message': e.message,
      }, 400);
    } on Exception catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      return Response.json({
        'success': false,
        'message': message,
      }, 400);
    }
  }

  /// GET /api/v1/orders
  Future<Response> index(Request request) async {
    try {
      final userId = _authUserId();
      if (userId == null) {
        return Response.json({
          'success': false,
          'message': 'Authentication required',
        }, 401);
      }

      final page = int.tryParse(request.input('page')?.toString() ?? '1') ?? 1;
      final perPage = int.tryParse(request.input('per_page')?.toString() ?? '20') ?? 20;

      final orders = await _service.getUserOrders(
        userId,
        page: page,
        perPage: perPage,
      );

      return Response.json({
        'success': true,
        'data': orders,
      }, 200);
    } catch (e) {
      return Response.json({
        'success': false,
        'message': 'Failed to fetch orders',
      }, 500);
    }
  }

  /// GET /api/v1/orders/{id}
  Future<Response> show(Request request, dynamic id) async {
    try {
      final userId = _authUserId();
      if (userId == null) {
        return Response.json({
          'success': false,
          'message': 'Authentication required',
        }, 401);
      }

      final orderId = int.parse(id.toString());
      final order = await _service.getOrderById(orderId, userId: userId);

      if (order == null) {
        return Response.json({
          'success': false,
          'message': 'Order not found',
        }, 404);
      }

      return Response.json({
        'success': true,
        'data': order,
      }, 200);
    } catch (e) {
      return Response.json({
        'success': false,
        'message': 'Failed to fetch order',
      }, 500);
    }
  }
}
