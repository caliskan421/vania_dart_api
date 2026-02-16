import 'package:first_vania_project/app/http/requests/base_request.dart';

class UpdateOrderStatusRequest extends BaseRequest {
  @override
  Map<String, String> rules() {
    return {
      'status': 'required|string',
    };
  }

  @override
  Map<String, String> messages() {
    return {
      'status.required': 'Order status is required',
    };
  }
}
