import 'package:first_vania_project/app/http/requests/base_request.dart';
import 'package:first_vania_project/app/validators/custom_rules.dart';
import 'package:vania/http/request.dart';

class ResetPasswordRequest extends BaseRequest {
  @override
  Map<String, String> rules() {
    return {
      'email': 'required|email',
      'token': 'required|string',
      'password': 'required|string|min_length:8|confirmed',
    };
  }

  @override
  Map<String, String> messages() {
    return {
      'email.required': 'Email is required',
      'email.email': 'Invalid email format',
      'token.required': 'Reset token is required',
      'password.required': 'Password is required',
      'password.min_length': 'Password must be at least 8 characters',
      'password.confirmed': 'Passwords do not match',
    };
  }

  @override
  List<CustomValidationRule> customRules() {
    return [CustomRules.strongPassword()];
  }
}
