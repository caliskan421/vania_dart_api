import 'package:first_vania_project/app/core/dto_schema.dart';
import 'package:first_vania_project/app/dto/order_item_dto.dart';
import 'package:vania/orm/model.dart';

class OrderItem extends Model with DtoSchema {
  @override
  String get tableName => 'order_items';

  @override
  List<FieldDef> get schema => [
        FieldDef('order_id', FieldType.integer),
        FieldDef('product_id', FieldType.integer),
        FieldDef('product_name', FieldType.string),
        FieldDef('quantity', FieldType.integer),
        FieldDef('unit_price', FieldType.double_),
        FieldDef('total_price', FieldType.double_),
      ];

  /// Tek kayıt — typed döner
  Future<OrderItemDto?> findById(int id) async {
    final map = await query.where('id', '=', id).first();
    return map != null ? OrderItemDto.fromMap(map) : null;
  }

  /// Siparişe ait kalemleri getir
  Future<List<OrderItemDto>> findByOrderId(int orderId) async {
    final maps = await query.where('order_id', '=', orderId).get();
    return maps.map(OrderItemDto.fromMap).toList();
  }
}
