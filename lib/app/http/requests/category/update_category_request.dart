import 'package:first_vania_project/app/http/requests/base_request.dart';

class UpdateCategoryRequest extends BaseRequest {
  @override
  Map<String, String> rules() {
    return {
      'name': 'nullable|string|min_length:2|max_length:100',
      'description': 'nullable|string',
      'is_active': 'nullable|boolean',
    };
  }

  @override
  Map<String, String> messages() {
    return {
      'name.min_length': 'Category name must be at least 2 characters',
      'name.max_length': 'Category name cannot exceed 100 characters',
    };
  }
}
