import 'package:vania/orm/model.dart';

class Product extends Model {
  @override
  String get tableName => 'products';

  final List<String> _fillable = [
    'category_id',
    'name',
    'slug',
    'description',
    'price',
    'discount_price',
    'stock',
    'sku',
    'is_active',
  ];

  @override
  List<String> get fillable => _fillable;
}
