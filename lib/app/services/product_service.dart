import 'package:first_vania_project/app/dto/product_dto.dart';
import 'package:first_vania_project/app/models/product.dart';
import 'package:first_vania_project/app/models/product_image.dart';
import 'package:first_vania_project/app/models/category.dart';

class ProductService {
  /// Ürünleri listele (arama, filtreleme, sayfalama destekli)
  Future<Map<String, dynamic>> getProducts({
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int perPage = 20,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    var query = Product().query.where('is_active', '=', true);

    if (search != null && search.isNotEmpty) {
      query = query.where('name', 'like', '%$search%');
    }

    if (categoryId != null) {
      query = query.where('category_id', '=', categoryId);
    }

    if (minPrice != null) {
      query = query.where('price', '>=', minPrice);
    }

    if (maxPrice != null) {
      query = query.where('price', '<=', maxPrice);
    }

    final allResults = await Product().query.where('is_active', '=', true).get();
    int totalFiltered = allResults.length;

    final offset = (page - 1) * perPage;
    final productMaps = await query.orderBy(sortBy, sortOrder).limit(perPage).offset(offset).get();

    final productList = <Map<String, dynamic>>[];
    for (final productMap in productMaps) {
      final product = ProductDto.fromMap(productMap);

      final images = await ProductImage()
          .query
          .where('product_id', '=', product.id)
          .orderBy('sort_order', 'asc')
          .get();

      Map<String, dynamic>? categoryData;
      if (product.categoryId != null) {
        categoryData = await Category()
            .query
            .where('id', '=', product.categoryId)
            .first();
      }

      productList.add({
        ...productMap,
        'images': images,
        'category': categoryData,
      });
    }

    return {
      'products': productList,
      'pagination': {
        'current_page': page,
        'per_page': perPage,
        'total': totalFiltered,
        'last_page': (totalFiltered / perPage).ceil(),
      },
    };
  }

  /// Tek ürün detayı
  Future<Map<String, dynamic>?> getProductById(int id) async {
    final productMap = await Product().query.where('id', '=', id).first();
    if (productMap == null) return null;
    final product = ProductDto.fromMap(productMap);

    final images = await ProductImage()
        .query
        .where('product_id', '=', product.id)
        .orderBy('sort_order', 'asc')
        .get();

    Map<String, dynamic>? categoryData;
    if (product.categoryId != null) {
      categoryData = await Category()
          .query
          .where('id', '=', product.categoryId)
          .first();
    }

    return {
      ...productMap,
      'images': images,
      'category': categoryData,
    };
  }

  /// Yeni ürün oluştur
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    final slug = _generateSlug(data['name'].toString());

    if (data['category_id'] != null) {
      final category = await Category().findById((data['category_id'] as num).toInt());
      if (category == null) {
        throw Exception('Category not found');
      }
    }

    await Product().query.insert({
      'category_id': data['category_id'],
      'name': data['name'],
      'slug': slug,
      'description': data['description'],
      'price': data['price'],
      'discount_price': data['discount_price'],
      'stock': data['stock'] ?? 0,
      'sku': data['sku'],
      'is_active': data['is_active'] ?? true,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    final product = await Product().query.where('slug', '=', slug).first();
    return product!;
  }

  /// Ürünü güncelle
  Future<Map<String, dynamic>> updateProduct(int id, Map<String, dynamic> data) async {
    final product = await Product().findById(id);
    if (product == null) {
      throw Exception('Product not found');
    }

    final updateData = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (data['name'] != null) {
      updateData['name'] = data['name'];
      updateData['slug'] = _generateSlug(data['name'].toString());
    }
    if (data.containsKey('description')) {
      updateData['description'] = data['description'];
    }
    if (data['price'] != null) updateData['price'] = data['price'];
    if (data.containsKey('discount_price')) {
      updateData['discount_price'] = data['discount_price'];
    }
    if (data['stock'] != null) updateData['stock'] = data['stock'];
    if (data.containsKey('sku')) updateData['sku'] = data['sku'];
    if (data['category_id'] != null) {
      updateData['category_id'] = data['category_id'];
    }
    if (data['is_active'] != null) {
      updateData['is_active'] = data['is_active'];
    }

    await Product().query.where('id', '=', id).update(updateData);

    return (await getProductById(id))!;
  }

  /// Ürünü sil (soft delete)
  Future<void> deleteProduct(int id) async {
    final product = await Product().findById(id);
    if (product == null) {
      throw Exception('Product not found');
    }
    await Product().query.where('id', '=', id).update({
      'is_active': false,
      'deleted_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Ürüne resim ekle
  Future<Map<String, dynamic>> addProductImage(int productId, String imageUrl, {bool isPrimary = false}) async {
    final product = await Product().findById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    final existingImages = await ProductImage()
        .query
        .where('product_id', '=', productId)
        .get();
    final sortOrder = existingImages.length;

    if (isPrimary) {
      await ProductImage()
          .query
          .where('product_id', '=', productId)
          .where('is_primary', '=', true)
          .update({'is_primary': false});
    }

    if (existingImages.isEmpty) {
      isPrimary = true;
    }

    await ProductImage().query.insert({
      'product_id': productId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
      'sort_order': sortOrder,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    final image = await ProductImage()
        .query
        .where('product_id', '=', productId)
        .where('image_url', '=', imageUrl)
        .first();
    return image!;
  }

  /// Stok kontrolü
  Future<bool> checkStock(int productId, int quantity) async {
    final product = await Product().findById(productId);
    if (product == null) return false;
    return product.stock >= quantity;
  }

  /// Stok azalt
  Future<void> decreaseStock(int productId, int quantity) async {
    final product = await Product().findById(productId);
    if (product == null) throw Exception('Product not found');
    final newStock = product.stock - quantity;
    if (newStock < 0) throw Exception('Insufficient stock');
    await Product().query.where('id', '=', productId).update({
      'stock': newStock,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  String _generateSlug(String name) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '').replaceAll(RegExp(r'\s+'), '-')}-$timestamp';
  }
}
