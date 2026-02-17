import 'package:first_vania_project/app/core/dto_schema.dart';
import 'package:first_vania_project/app/dto/user_dto.dart';
import 'package:vania/orm/model.dart';

class User extends Model with DtoSchema {
  @override
  String get tableName => 'users';

  @override
  List<FieldDef> get schema => [
    FieldDef('name', FieldType.string),
    FieldDef('email', FieldType.string),
    FieldDef('password', FieldType.string),
    FieldDef('phone', FieldType.string, nullable: true),
    FieldDef('role', FieldType.string),
    FieldDef('avatar_url', FieldType.string, nullable: true),
    FieldDef('address', FieldType.string, nullable: true),
  ];

  /// Tek kayıt — typed döner
  Future<UserDto?> findById(int id) async {
    final map = await query.where('id', '=', id).first();
    return map != null ? UserDto.fromMap(map) : null;
  }

  /// Liste — typed döner
  Future<List<UserDto>> findAll() async {
    final maps = await query.get();
    return maps.map(UserDto.fromMap).toList();
  }

  /// E-posta ile bul
  Future<UserDto?> findByEmail(String email) async {
    final map = await query.where('email', '=', email).first();
    return map != null ? UserDto.fromMap(map) : null;
  }
}
