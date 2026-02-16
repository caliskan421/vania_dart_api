import 'package:first_vania_project/app/http/requests/base_request.dart';

class LoginRequest extends BaseRequest {
  @override
  Map<String, String> rules() {
    return {
      'email': 'required|email',
      'password': 'required|string',
    };
  }

  @override
  Map<String, String> messages() {
    return {
      'email.required': 'Email is required',
      'email.email': 'Invalid email format',
      'password.required': 'Password is required',
    };
  }
}
