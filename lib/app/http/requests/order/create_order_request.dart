import 'package:first_vania_project/app/http/requests/base_request.dart';
import 'package:first_vania_project/app/validators/custom_rules.dart';
import 'package:vania/http/request.dart';

class CreateOrderRequest extends BaseRequest {
  @override
  Map<String, String> rules() {
    return {
      'shipping_address': 'required|string|min_length:10|max_length:500',
      'shipping_city': 'required|string|min_length:2|max_length:100',
      'shipping_phone': 'required|string',
      'notes': 'nullable|string|max_length:500',
    };
  }

  @override
  Map<String, String> messages() {
    return {
      'shipping_address.required': 'Shipping address is required',
      'shipping_address.min_length': 'Shipping address must be at least 10 characters',
      'shipping_city.required': 'Shipping city is required',
      'shipping_phone.required': 'Shipping phone is required',
      'notes.max_length': 'Notes cannot exceed 500 characters',
    };
  }

  @override
  List<CustomValidationRule> customRules() {
    return [CustomRules.turkishPhone()];
  }
}
