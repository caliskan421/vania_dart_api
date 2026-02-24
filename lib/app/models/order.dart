import 'package:first_vania_project/app/core/dto_schema.dart';
import 'package:first_vania_project/app/dto/order_dto.dart';
import 'package:vania/orm/model.dart';

class Order extends Model with DtoSchema {
  @override
  String get tableName => 'orders';

  @override
  List<FieldDef> get schema => [
        FieldDef('user_id', FieldType.integer),
        FieldDef('order_number', FieldType.string),
        FieldDef('status', FieldType.string),
        FieldDef('subtotal', FieldType.double_),
        FieldDef('tax_amount', FieldType.double_),
        FieldDef('shipping_cost', FieldType.double_),
        FieldDef('total_amount', FieldType.double_),
        FieldDef('shipping_address', FieldType.string, nullable: true),
        FieldDef('shipping_city', FieldType.string, nullable: true),
        FieldDef('shipping_phone', FieldType.string, nullable: true),
        FieldDef('notes', FieldType.string, nullable: true),
        FieldDef('invoice_path', FieldType.string, nullable: true),
      ];

  /// Tek kayıt — typed döner
  Future<OrderDto?> findById(int id) async {
    final map = await query.where('id', '=', id).first();
    return map != null ? OrderDto.fromMap(map) : null;
  }

  /// Liste — typed döner
  Future<List<OrderDto>> findAll() async {
    final maps = await query.get();
    return maps.map(OrderDto.fromMap).toList();
  }

  /// Sipariş numarası ile bul
  Future<OrderDto?> findByOrderNumber(String orderNumber) async {
    final map = await query.where('order_number', '=', orderNumber).first();
    return map != null ? OrderDto.fromMap(map) : null;
  }
}
