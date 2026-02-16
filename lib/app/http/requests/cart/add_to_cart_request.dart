import 'package:first_vania_project/app/http/requests/base_request.dart';

class AddToCartRequest extends BaseRequest {
  @override
  Map<String, String> rules() {
    return {
      'product_id': 'required|integer',
      'quantity': 'required|integer|min:1',
    };
  }

  @override
  Map<String, String> messages() {
    return {
      'product_id.required': 'Product ID is required',
      'product_id.integer': 'Product ID must be an integer',
      'quantity.required': 'Quantity is required',
      'quantity.integer': 'Quantity must be an integer',
      'quantity.min': 'Quantity must be at least 1',
    };
  }
}
