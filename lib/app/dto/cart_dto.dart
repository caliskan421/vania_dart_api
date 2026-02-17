// GENERATED — dart run tool/generate_dto.dart
// Bu dosya otomatik üretilmiştir. Elle düzenleme yapılabilir,
// ancak --force ile yeniden üretildiğinde değişiklikler kaybolur.

class CartDto {
  final int id;
  final int userId;

  const CartDto({
    required this.id,
    required this.userId,
  });

  factory CartDto.fromMap(Map<String, dynamic> map) {
    return CartDto(
      id: _parseInt(map['id']),
      userId: _parseInt(map['user_id']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
    };
  }
  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
