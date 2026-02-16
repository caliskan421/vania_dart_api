import 'package:vania/orm/model.dart';

class ProductImage extends Model {
  @override
  String get tableName => 'product_images';

  final List<String> _fillable = [
    'product_id',
    'image_url',
    'is_primary',
    'sort_order',
  ];

  @override
  List<String> get fillable => _fillable;
}
