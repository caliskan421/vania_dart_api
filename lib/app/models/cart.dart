import 'package:first_vania_project/app/core/dto_schema.dart';
import 'package:first_vania_project/app/dto/cart_dto.dart';
import 'package:vania/orm/model.dart';

class Cart extends Model with DtoSchema {
  @override
  String get tableName => 'carts';

  @override
  List<FieldDef> get schema => [
        FieldDef('user_id', FieldType.integer),
      ];

  /// Tek kayıt — typed döner
  Future<CartDto?> findById(int id) async {
    final map = await query.where('id', '=', id).first();
    return map != null ? CartDto.fromMap(map) : null;
  }

  /// Kullanıcıya ait sepeti bul
  Future<CartDto?> findByUserId(int userId) async {
    final map = await query.where('user_id', '=', userId).first();
    return map != null ? CartDto.fromMap(map) : null;
  }
}
