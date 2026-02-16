import 'package:first_vania_project/app/http/requests/base_request.dart';

class ForgotPasswordRequest extends BaseRequest {
  @override
  Map<String, String> rules() {
    return {
      'email': 'required|email',
    };
  }

  @override
  Map<String, String> messages() {
    return {
      'email.required': 'Email is required',
      'email.email': 'Invalid email format',
    };
  }
}
