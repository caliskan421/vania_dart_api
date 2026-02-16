import 'package:first_vania_project/app/http/requests/base_request.dart';

class UpdateProductRequest extends BaseRequest {
  @override
  Map<String, String> rules() {
    return {
      'name': 'nullable|string|min_length:2|max_length:255',
      'description': 'nullable|string',
      'price': 'nullable|numeric',
      'discount_price': 'nullable|numeric',
      'stock': 'nullable|integer',
      'sku': 'nullable|string|max_length:100',
      'category_id': 'nullable|integer',
      'is_active': 'nullable|boolean',
    };
  }

  @override
  Map<String, String> messages() {
    return {
      'name.min_length': 'Product name must be at least 2 characters',
      'price.numeric': 'Price must be a number',
      'stock.integer': 'Stock must be an integer',
      'category_id.integer': 'Category ID must be an integer',
    };
  }
}
