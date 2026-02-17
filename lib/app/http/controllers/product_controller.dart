import 'package:first_vania_project/app/http/requests/product/create_product_request.dart';
import 'package:first_vania_project/app/http/requests/product/update_product_request.dart';
import 'package:first_vania_project/app/services/product_service.dart';
import 'package:first_vania_project/app/services/file_upload_service.dart';
import 'package:vania/http/controller.dart';
import 'package:vania/http/request.dart';
import 'package:vania/http/response.dart';
import 'package:vania/src/exception/invalid_argument_exception.dart';
import 'package:vania/vania.dart';

class ProductController extends Controller {
  final ProductService _service = ProductService();
  final FileUploadService _fileService = FileUploadService();

  /// GET /api/v1/products
  Future<Response> index(Request request) async {
    try {
      final search = request.input('search')?.toString();
      final categoryId = request.input('category_id') != null ? int.tryParse(request.input('category_id').toString()) : null;
      final minPrice = request.input('min_price') != null ? double.tryParse(request.input('min_price').toString()) : null;
      final maxPrice = request.input('max_price') != null ? double.tryParse(request.input('max_price').toString()) : null;
      final page = int.tryParse(request.input('page')?.toString() ?? '1') ?? 1;
      final perPage = int.tryParse(request.input('per_page')?.toString() ?? '20') ?? 20;
      final sortBy = request.input('sort_by')?.toString() ?? 'created_at';
      final sortOrder = request.input('sort_order')?.toString() ?? 'desc';

      final result = await _service.getProducts(
        search: search,
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        page: page,
        perPage: perPage,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      return Response.json({
        'success': true,
        'data': result['products'],
        'pagination': result['pagination'],
      }, 200);
    } catch (e) {
      return Response.json({
        'success': false,
        'message': 'Failed to fetch products',
      }, 500);
    }
  }

  /// GET /api/v1/products/{id}
  Future<Response> show(Request request, dynamic id) async {
    try {
      final productId = int.parse(id.toString());
      final product = await _service.getProductById(productId);

      if (product == null) {
        return Response.json({
          'success': false,
          'message': 'Product not found',
        }, 404);
      }

      return Response.json({
        'success': true,
        'data': product,
      }, 200);
    } catch (e) {
      return Response.json({
        'success': false,
        'message': 'Failed to fetch product',
      }, 500);
    }
  }

  /// POST /api/v1/admin/products
  Future<Response> store(Request request) async {
    try {
      await CreateProductRequest().validate(request);
    } on ValidationException catch (e) {
      return Response.json({
        'success': false,
        'message': 'Validation failed',
        'errors': e.message,
      }, 422);
    }

    try {
      final product = await _service.createProduct({
        'name': request.input('name'),
        'description': request.input('description'),
        'price': request.input('price'),
        'discount_price': request.input('discount_price'),
        'stock': request.input('stock'),
        'sku': request.input('sku'),
        'category_id': request.input('category_id'),
        'is_active': request.input('is_active') ?? true,
      });

      return Response.json({
        'success': true,
        'message': 'Product created successfully',
        'data': product,
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

  /// PUT /api/v1/admin/products/{id}
  Future<Response> update(Request request, dynamic id) async {
    try {
      await UpdateProductRequest().validate(request);
    } on ValidationException catch (e) {
      return Response.json({
        'success': false,
        'message': 'Validation failed',
        'errors': e.message,
      }, 422);
    }

    try {
      final productId = int.parse(id.toString());
      final product = await _service.updateProduct(productId, {
        'name': request.input('name'),
        'description': request.input('description'),
        'price': request.input('price'),
        'discount_price': request.input('discount_price'),
        'stock': request.input('stock'),
        'sku': request.input('sku'),
        'category_id': request.input('category_id'),
        'is_active': request.input('is_active'),
      });

      return Response.json({
        'success': true,
        'message': 'Product updated successfully',
        'data': product,
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

  /// DELETE /api/v1/admin/products/{id}
  Future<Response> destroy(Request request, dynamic id) async {
    try {
      final productId = int.parse(id.toString());
      await _service.deleteProduct(productId);

      return Response.json({
        'success': true,
        'message': 'Product deleted successfully',
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

  /// POST /api/v1/admin/products/{id}/images
  Future<Response> uploadImages(Request request, dynamic id) async {
    try {
      final productId = int.parse(id.toString());
      final file = request.file('image');

      if (file == null) {
        return Response.json({
          'success': false,
          'message': 'Image file is required',
        }, 422);
      }

      final isPrimary = request.input('is_primary') == true || request.input('is_primary') == 'true';

      final extension = file.extension;
      if (!_fileService.isAllowedImageExtension(extension)) {
        return Response.json({
          'success': false,
          'message': 'Invalid file type. Allowed: jpg, jpeg, png, gif, webp',
        }, 422);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'product_${productId}_$timestamp.$extension';
      await file.move(toPath: 'public/products', name: filename);
      final imageUrl = '/products/$filename';

      final image = await _service.addProductImage(
        productId,
        imageUrl,
        isPrimary: isPrimary,
      );

      return Response.json({
        'success': true,
        'message': 'Image uploaded successfully',
        'data': image,
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
}
