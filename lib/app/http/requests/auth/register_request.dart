import 'package:first_vania_project/app/http/requests/base_request.dart';
import 'package:first_vania_project/app/validators/custom_rules.dart';
import 'package:vania/http/request.dart';

class RegisterRequest extends BaseRequest {
  @override
  Map<String, String> rules() {
    return {
      'name': 'required|string|min_length:2|max_length:100',
      'email': 'required|email',
      'password': 'required|string|min_length:8|confirmed',
      'phone': 'nullable|string',
    };
  }

  @override
  Map<String, String> messages() {
    return {
      'name.required': 'Name is required',
      'name.min_length': 'Name must be at least 2 characters',
      'name.max_length': 'Name cannot exceed 100 characters',
      'email.required': 'Email is required',
      'email.email': 'Invalid email format',
      'password.required': 'Password is required',
      'password.min_length': 'Password must be at least 8 characters',
      'password.confirmed': 'Passwords do not match',
      'phone.string': 'Phone must be a string',
    };
  }

  @override
  List<CustomValidationRule> customRules() {
    return [
      CustomRules.strongPassword(),
      CustomRules.uniqueEmail(),
      CustomRules.turkishPhone(),
    ];
  }
}
