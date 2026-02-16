import 'package:first_vania_project/app/http/requests/base_request.dart';
import 'package:first_vania_project/app/validators/custom_rules.dart';
import 'package:vania/http/request.dart';

class UpdateProfileRequest extends BaseRequest {
  @override
  Map<String, String> rules() {
    return {
      'name': 'nullable|string|min_length:2|max_length:100',
      'phone': 'nullable|string',
      'address': 'nullable|string|max_length:500',
    };
  }

  @override
  Map<String, String> messages() {
    return {
      'name.min_length': 'Name must be at least 2 characters',
      'name.max_length': 'Name cannot exceed 100 characters',
      'address.max_length': 'Address cannot exceed 500 characters',
    };
  }

  @override
  List<CustomValidationRule> customRules() {
    return [CustomRules.turkishPhone()];
  }
}
