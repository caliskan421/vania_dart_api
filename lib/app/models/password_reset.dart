import 'package:first_vania_project/app/core/dto_schema.dart';
import 'package:first_vania_project/app/dto/password_reset_dto.dart';
import 'package:vania/orm/model.dart';

class PasswordReset extends Model with DtoSchema {
  @override
  String get tableName => 'password_resets';

  @override
  List<FieldDef> get schema => [
        FieldDef('email', FieldType.string),
        FieldDef('token', FieldType.string),
        FieldDef('is_used', FieldType.boolean),
        FieldDef('expires_at', FieldType.dateTime),
      ];

  /// Tek kayıt — typed döner
  Future<PasswordResetDto?> findById(int id) async {
    final map = await query.where('id', '=', id).first();
    return map != null ? PasswordResetDto.fromMap(map) : null;
  }

  /// E-posta ile aktif (kullanılmamış) reset kaydını bul
  Future<PasswordResetDto?> findActiveByEmail(String email) async {
    final map = await query.where('email', '=', email).where('is_used', '=', false).first();
    return map != null ? PasswordResetDto.fromMap(map) : null;
  }
}
