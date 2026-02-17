import 'package:first_vania_project/app/http/requests/cart/add_to_cart_request.dart';
import 'package:first_vania_project/app/http/requests/cart/update_cart_request.dart';
import 'package:first_vania_project/app/services/cart_service.dart';
import 'package:vania/authentication.dart';
import 'package:vania/http/controller.dart';
import 'package:vania/http/request.dart';
import 'package:vania/http/response.dart';
import 'package:vania/src/exception/invalid_argument_exception.dart';
import 'package:vania/vania.dart';

class CartController extends Controller {
  final CartService _service = CartService();

  int? _authUserId() {
    final rawUserId = Auth().user()['id'];
    if (rawUserId == null) return null;
    if (rawUserId is int) return rawUserId;
    if (rawUserId is num) return rawUserId.toInt();
    return int.tryParse(rawUserId.toString());
  }

  /// GET /api/v1/cart
  Future<Response> index(Request request) async {
    try {
      final userId = _authUserId();
      if (userId == null) {
        return Response.json({
          'success': false,
          'message': 'Authentication required',
        }, 401);
      }

      final cart = await _service.getCartWithItems(userId);

      return Response.json({
        'success': true,
        'data': cart,
      }, 200);
    } catch (e) {
      return Response.json({
        'success': false,
        'message': 'Failed to fetch cart',
      }, 500);
    }
  }

  /// POST /api/v1/cart/items
  Future<Response> addItem(Request request) async {
    try {
      await AddToCartRequest().validate(request);
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

      final productId = int.parse(request.input('product_id').toString());
      final quantity = int.parse(request.input('quantity').toString());

      final cart = await _service.addItem(userId, productId, quantity);

      return Response.json({
        'success': true,
        'message': 'Item added to cart',
        'data': cart,
      }, 200);
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

  /// PUT /api/v1/cart/items/{id}
  Future<Response> updateItem(Request request, dynamic id) async {
    try {
      await UpdateCartRequest().validate(request);
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

      final cartItemId = int.parse(id.toString());
      final quantity = int.parse(request.input('quantity').toString());

      final cart = await _service.updateItemQuantity(userId, cartItemId, quantity);

      return Response.json({
        'success': true,
        'message': 'Cart item updated',
        'data': cart,
      }, 200);
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

  /// DELETE /api/v1/cart/items/{id}
  Future<Response> removeItem(Request request, dynamic id) async {
    try {
      final userId = _authUserId();
      if (userId == null) {
        return Response.json({
          'success': false,
          'message': 'Authentication required',
        }, 401);
      }

      final cartItemId = int.parse(id.toString());
      final cart = await _service.removeItem(userId, cartItemId);

      return Response.json({
        'success': true,
        'message': 'Item removed from cart',
        'data': cart,
      }, 200);
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

  /// DELETE /api/v1/cart
  Future<Response> clear(Request request) async {
    try {
      final userId = _authUserId();
      if (userId == null) {
        return Response.json({
          'success': false,
          'message': 'Authentication required',
        }, 401);
      }

      await _service.clearCart(userId);

      return Response.json({
        'success': true,
        'message': 'Cart cleared successfully',
      }, 200);
    } catch (e) {
      return Response.json({
        'success': false,
        'message': 'Failed to clear cart',
      }, 500);
    }
  }
}
