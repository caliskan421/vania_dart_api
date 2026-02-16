import 'package:vania/orm/model.dart';

class User extends Model {
  @override
  String get tableName => 'users';

  final List<String> _fillable = [
    'name',
    'email',
    'password',
    'phone',
    'role',
    'avatar_url',
    'address',
  ];

  @override
  List<String> get fillable => _fillable;
}
