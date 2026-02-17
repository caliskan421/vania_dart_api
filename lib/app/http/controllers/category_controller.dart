import 'package:first_vania_project/app/http/requests/category/create_category_request.dart';
import 'package:first_vania_project/app/http/requests/category/update_category_request.dart';
import 'package:first_vania_project/app/services/category_service.dart';
import 'package:vania/http/controller.dart';
import 'package:vania/http/request.dart';
import 'package:vania/http/response.dart';
import 'package:vania/src/exception/invalid_argument_exception.dart';
import 'package:vania/vania.dart';

class CategoryController extends Controller {
  final CategoryService _service = CategoryService();

  /// GET /api/v1/categories
  Future<Response> index(Request request) async {
    try {
      final categories = await _service.getAllCategories(activeOnly: true);

      return Response.json({
        'success': true,
        'data': categories,
      }, 200);
    } catch (e) {
      return Response.json({
        'success': false,
        'message': 'Failed to fetch categories',
      }, 500);
    }
  }

  /// GET /api/v1/categories/{id}
  Future<Response> show(Request request, dynamic id) async {
    try {
      final categoryId = int.parse(id.toString());
      final category = await _service.getCategoryById(categoryId);

      if (category == null) {
        return Response.json({
          'success': false,
          'message': 'Category not found',
        }, 404);
      }

      return Response.json({
        'success': true,
        'data': category,
      }, 200);
    } catch (e) {
      return Response.json({
        'success': false,
        'message': 'Failed to fetch category',
      }, 500);
    }
  }

  /// POST /api/v1/admin/categories
  Future<Response> store(Request request) async {
    try {
      await CreateCategoryRequest().validate(request);
    } on ValidationException catch (e) {
      return Response.json({
        'success': false,
        'message': 'Validation failed',
        'errors': e.message,
      }, 422);
    }

    try {
      final category = await _service.createCategory({
        'name': request.input('name'),
        'description': request.input('description'),
        'image_url': request.input('image_url'),
        'is_active': request.input('is_active') ?? true,
      });

      return Response.json({
        'success': true,
        'message': 'Category created successfully',
        'data': category,
      }, 201);
    } on InvalidArgumentException catch (e) {
      return Response.json({
        'success': false,
        'message': e.message,
      }, 400);
    } on Exception catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      return Response.json({
        'success': false,
        'message': message,
      }, 400);
    }
  }

  /// PUT /api/v1/admin/categories/{id}
  Future<Response> update(Request request, dynamic id) async {
    try {
      await UpdateCategoryRequest().validate(request);
    } on ValidationException catch (e) {
      return Response.json({
        'success': false,
        'message': 'Validation failed',
        'errors': e.message,
      }, 422);
    }

    try {
      final categoryId = int.parse(id.toString());
      final category = await _service.updateCategory(categoryId, {
        'name': request.input('name'),
        'description': request.input('description'),
        'image_url': request.input('image_url'),
        'is_active': request.input('is_active'),
      });

      return Response.json({
        'success': true,
        'message': 'Category updated successfully',
        'data': category,
      }, 200);
    } on InvalidArgumentException catch (e) {
      return Response.json({
        'success': false,
        'message': e.message,
      }, 400);
    } on Exception catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      return Response.json({
        'success': false,
        'message': message,
      }, 400);
    }
  }

  /// DELETE /api/v1/admin/categories/{id}
  Future<Response> destroy(Request request, dynamic id) async {
    try {
      final categoryId = int.parse(id.toString());
      await _service.deleteCategory(categoryId);

      return Response.json({
        'success': true,
        'message': 'Category deleted successfully',
      }, 200);
    } on InvalidArgumentException catch (e) {
      return Response.json({
        'success': false,
        'message': e.message,
      }, 400);
    } on Exception catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      return Response.json({
        'success': false,
        'message': message,
      }, 400);
    }
  }
}
