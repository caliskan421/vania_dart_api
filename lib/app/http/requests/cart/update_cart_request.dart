import 'package:first_vania_project/app/http/requests/base_request.dart';

class UpdateCartRequest extends BaseRequest {
  @override
  Map<String, String> rules() {
    return {
      'quantity': 'required|integer|min:1',
    };
  }

  @override
  Map<String, String> messages() {
    return {
      'quantity.required': 'Quantity is required',
      'quantity.integer': 'Quantity must be an integer',
      'quantity.min': 'Quantity must be at least 1',
    };
  }
}
