import 'package:first_vania_project/app/core/dto_schema.dart';
import 'package:first_vania_project/app/dto/category_dto.dart';
import 'package:vania/orm/model.dart';

class Category extends Model with DtoSchema {
  @override
  String get tableName => 'categories';

  @override
  List<FieldDef> get schema => [
    FieldDef('name', FieldType.string),
    FieldDef('slug', FieldType.string),
    FieldDef('description', FieldType.string, nullable: true),
    FieldDef('image_url', FieldType.string, nullable: true),
    FieldDef('is_active', FieldType.boolean),
  ];

  /// Tek kayıt — typed döner
  Future<CategoryDto?> findById(int id) async {
    final map = await query.where('id', '=', id).first();
    return map != null ? CategoryDto.fromMap(map) : null;
  }

  /// Liste — typed döner
  Future<List<CategoryDto>> findAll() async {
    final maps = await query.get();
    return maps.map(CategoryDto.fromMap).toList();
  }
}
