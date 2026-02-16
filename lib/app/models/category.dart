import 'package:vania/orm/model.dart';

class Category extends Model {
  @override
  String get tableName => 'categories';

  final List<String> _fillable = [
    'name',
    'slug',
    'description',
    'image_url',
    'is_active',
  ];

  @override
  List<String> get fillable => _fillable;
}
