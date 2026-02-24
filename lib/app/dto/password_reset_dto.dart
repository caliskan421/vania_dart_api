// GENERATED — dart run tool/generate_dto.dart
// Bu dosya otomatik üretilmiştir. Elle düzenleme yapılabilir,
// ancak --force ile yeniden üretildiğinde değişiklikler kaybolur.

class PasswordResetDto {
  final int id;
  final String email;
  final String token;
  final bool isUsed;
  final DateTime expiresAt;

  const PasswordResetDto({
    required this.id,
    required this.email,
    required this.token,
    required this.isUsed,
    required this.expiresAt,
  });

  factory PasswordResetDto.fromMap(Map<String, dynamic> map) {
    return PasswordResetDto(
      id: _parseInt(map['id']),
      email: map['email'] as String,
      token: map['token'] as String,
      isUsed: _parseBool(map['is_used']),
      expiresAt: DateTime.parse(map['expires_at'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'token': token,
      'is_used': isUsed,
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  /// Token süresi dolmuş mu?
  bool get isExpired => DateTime.now().isAfter(expiresAt);

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
}
