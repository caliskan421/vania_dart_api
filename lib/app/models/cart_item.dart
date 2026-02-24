import 'package:first_vania_project/app/core/dto_schema.dart';
import 'package:first_vania_project/app/dto/cart_item_dto.dart';
import 'package:vania/orm/model.dart';

class CartItem extends Model with DtoSchema {
  @override
  String get tableName => 'cart_items';

  @override
  List<FieldDef> get schema => [
        FieldDef('cart_id', FieldType.integer),
        FieldDef('product_id', FieldType.integer),
        FieldDef('quantity', FieldType.integer),
        FieldDef('unit_price', FieldType.double_),
      ];

  /// Tek kayıt — typed döner
  Future<CartItemDto?> findById(int id) async {
    final map = await query.where('id', '=', id).first();
    return map != null ? CartItemDto.fromMap(map) : null;
  }

  /// Sepete ait kalemleri getir
  Future<List<CartItemDto>> findByCartId(int cartId) async {
    final maps = await query.where('cart_id', '=', cartId).get();
    return maps.map(CartItemDto.fromMap).toList();
  }
}
