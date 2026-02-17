// GENERATED — dart run tool/generate_dto.dart
// Bu dosya otomatik üretilmiştir. Elle düzenleme yapılabilir,
// ancak --force ile yeniden üretildiğinde değişiklikler kaybolur.

class UserDto {
  final int id;
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String role;
  final String? avatarUrl;
  final String? address;

  const UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    required this.role,
    this.avatarUrl,
    this.address,
  });

  factory UserDto.fromMap(Map<String, dynamic> map) {
    return UserDto(
      id: _parseInt(map['id']),
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      phone: map['phone'] as String?,
      role: map['role'] as String,
      avatarUrl: map['avatar_url'] as String?,
      address: map['address'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
      'avatar_url': avatarUrl,
      'address': address,
    };
  }
  /// Admin mi?
  bool get isAdmin => role == 'admin';

  /// Hassas alanlar (password) olmadan map döner — API response için
  Map<String, dynamic> toSanitizedMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'avatar_url': avatarUrl,
      'address': address,
    };
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
