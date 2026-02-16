import 'package:vania/orm/model.dart';

class Cart extends Model {
  @override
  String get tableName => 'carts';

  final List<String> _fillable = [
    'user_id',
  ];

  @override
  List<String> get fillable => _fillable;
}
