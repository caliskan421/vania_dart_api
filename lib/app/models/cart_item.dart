import 'package:vania/orm/model.dart';

class CartItem extends Model {
  @override
  String get tableName => 'cart_items';

  final List<String> _fillable = [
    'cart_id',
    'product_id',
    'quantity',
    'unit_price',
  ];

  @override
  List<String> get fillable => _fillable;
}
