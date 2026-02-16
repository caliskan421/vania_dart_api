import 'package:vania/orm/model.dart';

class Order extends Model {
  @override
  String get tableName => 'orders';

  final List<String> _fillable = [
    'user_id',
    'order_number',
    'status',
    'subtotal',
    'tax_amount',
    'shipping_cost',
    'total_amount',
    'shipping_address',
    'shipping_city',
    'shipping_phone',
    'notes',
    'invoice_path',
  ];

  @override
  List<String> get fillable => _fillable;
}
