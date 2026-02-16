import 'package:vania/orm/model.dart';

class OrderItem extends Model {
  @override
  String get tableName => 'order_items';

  final List<String> _fillable = [
    'order_id',
    'product_id',
    'product_name',
    'quantity',
    'unit_price',
    'total_price',
  ];

  @override
  List<String> get fillable => _fillable;
}
