// GENERATED — dart run tool/generate_dto.dart
// Bu dosya otomatik üretilmiştir. Elle düzenleme yapılabilir,
// ancak --force ile yeniden üretildiğinde değişiklikler kaybolur.

class StudentDto {
  final int id;
  final String name;
  final String email;
  final int age;
  final double? gpa;
  final String? bio;
  final bool isActive;
  final DateTime createdAt;

  const StudentDto({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    this.gpa,
    this.bio,
    required this.isActive,
    required this.createdAt,
  });

  factory StudentDto.fromMap(Map<String, dynamic> map) {
    return StudentDto(
      id: _parseInt(map['id']),
      name: map['name'] as String,
      email: map['email'] as String,
      age: _parseInt(map['age']),
      gpa: map['gpa'] != null ? _parseDouble(map['gpa']) : null,
      bio: map['bio'] as String?,
      isActive: _parseBool(map['is_active']),
      createdAt: DateTime.parse(map['created_at'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'gpa': gpa,
      'bio': bio,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v == 1;
    final s = v.toString().trim().toLowerCase();
    return s == '1' || s == 'true';
  }
  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
  static double _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
