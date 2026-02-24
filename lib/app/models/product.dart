import 'package:first_vania_project/app/core/dto_schema.dart';
import 'package:first_vania_project/app/dto/product_dto.dart';
import 'package:vania/orm/model.dart';

class Product extends Model with DtoSchema {
  @override
  String get tableName => 'products';

  @override
  List<FieldDef> get schema => [
        FieldDef('category_id', FieldType.integer),
        FieldDef('name', FieldType.string),
        FieldDef('slug', FieldType.string),
        FieldDef('description', FieldType.string, nullable: true),
        FieldDef('price', FieldType.double_),
        FieldDef('discount_price', FieldType.double_, nullable: true),
        FieldDef('stock', FieldType.integer),
        FieldDef('sku', FieldType.string),
        FieldDef('is_active', FieldType.boolean),
      ];

  /// Tek kayıt — typed döner
  Future<ProductDto?> findById(int id) async {
    final map = await query.where('id', '=', id).first();
    return map != null ? ProductDto.fromMap(map) : null;
  }

  /// Liste — typed döner
  Future<List<ProductDto>> findAll() async {
    final maps = await query.get();
    return maps.map(ProductDto.fromMap).toList();
  }

  /// Slug ile bul
  Future<ProductDto?> findBySlug(String slug) async {
    final map = await query.where('slug', '=', slug).first();
    return map != null ? ProductDto.fromMap(map) : null;
  }
}
