import 'package:first_vania_project/app/core/dto_schema.dart';
import 'package:first_vania_project/app/dto/student_dto.dart';
import 'package:vania/orm/model.dart';

class Student extends Model with DtoSchema {
  @override
  String get tableName => 'students';

  @override
  List<FieldDef> get schema => [
        FieldDef('name', FieldType.string),
        FieldDef('email', FieldType.string),
        FieldDef('age', FieldType.integer),
        FieldDef('gpa', FieldType.double_, nullable: true),
        FieldDef('bio', FieldType.string, nullable: true),
        FieldDef('is_active', FieldType.boolean),
        FieldDef('created_at', FieldType.dateTime),
      ];

  Future<StudentDto?> findById(int id) async {
    final map = await query.where('id', '=', id).first();
    return map != null ? StudentDto.fromMap(map) : null;
  }

  Future<List<StudentDto>> findAll() async {
    final maps = await query.get();
    return maps.map(StudentDto.fromMap).toList();
  }
}
