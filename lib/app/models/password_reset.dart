import 'package:vania/orm/model.dart';

class PasswordReset extends Model {
  @override
  String get tableName => 'password_resets';

  final List<String> _fillable = [
    'email',
    'token',
    'is_used',
    'expires_at',
  ];

  @override
  List<String> get fillable => _fillable;
}
