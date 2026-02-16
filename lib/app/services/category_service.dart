import 'package:first_vania_project/app/models/category.dart';
import 'package:vania/query_builder.dart';

class CategoryService {
  /// Tüm kategorileri getir
  Future<List<Map<String, dynamic>>> getAllCategories({
    bool activeOnly = false,
  }) async {
    QueryBuilder query = Category().query;
    if (activeOnly) {
      query = query.where('is_active', '=', true);
    }
    final categories = await query.orderBy('name', 'asc').get();
    return categories.cast<Map<String, dynamic>>();
  }

  /// Kategori detayını getir
  Future<Map<String, dynamic>?> getCategoryById(int id) async {
    final category = await Category().query.where('id', '=', id).first();
    return category;
  }

  /// Yeni kategori oluştur
  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) async {
    final slug = _generateSlug(data['name'].toString());

    await Category().query.insert({
      'name': data['name'],
      'slug': slug,
      'description': data['description'],
      'image_url': data['image_url'],
      'is_active': data['is_active'] ?? true,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    final category = await Category().query.where('slug', '=', slug).first();
    return category!;
  }

  /// Kategoriyi güncelle
  Future<Map<String, dynamic>> updateCategory(int id, Map<String, dynamic> data) async {
    final category = await Category().query.where('id', '=', id).first();
    if (category == null) {
      throw Exception('Category not found');
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
    if (data.containsKey('image_url')) {
      updateData['image_url'] = data['image_url'];
    }
    if (data['is_active'] != null) {
      updateData['is_active'] = data['is_active'];
    }

    await Category().query.where('id', '=', id).update(updateData);
    final updated = await Category().query.where('id', '=', id).first();
    return updated!;
  }

  /// Kategoriyi sil
  Future<void> deleteCategory(int id) async {
    final category = await Category().query.where('id', '=', id).first();
    if (category == null) {
      throw Exception('Category not found');
    }
    await Category().query.where('id', '=', id).delete();
  }

  /// Slug oluştur
  String _generateSlug(String name) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '').replaceAll(RegExp(r'\s+'), '-')}-$timestamp';
  }
}
