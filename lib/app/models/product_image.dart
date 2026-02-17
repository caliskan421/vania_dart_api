import 'package:first_vania_project/app/core/dto_schema.dart';
import 'package:first_vania_project/app/dto/product_image_dto.dart';
import 'package:vania/orm/model.dart';

class ProductImage extends Model with DtoSchema {
  @override
  String get tableName => 'product_images';

  @override
  List<FieldDef> get schema => [
    FieldDef('product_id', FieldType.integer),
    FieldDef('image_url', FieldType.string),
    FieldDef('is_primary', FieldType.boolean),
    FieldDef('sort_order', FieldType.integer),
  ];

  /// Tek kayıt — typed döner
  Future<ProductImageDto?> findById(int id) async {
    final map = await query.where('id', '=', id).first();
    return map != null ? ProductImageDto.fromMap(map) : null;
  }

  /// Ürüne ait resimleri getir (sıralı)
  Future<List<ProductImageDto>> findByProductId(int productId) async {
    final maps = await query
        .where('product_id', '=', productId)
        .orderBy('sort_order', 'asc')
        .get();
    return maps.map(ProductImageDto.fromMap).toList();
  }
}
