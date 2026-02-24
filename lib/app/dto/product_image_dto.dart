// GENERATED — dart run tool/generate_dto.dart
// Bu dosya otomatik üretilmiştir. Elle düzenleme yapılabilir,
// ancak --force ile yeniden üretildiğinde değişiklikler kaybolur.

class ProductImageDto {
  final int id;
  final int productId;
  final String imageUrl;
  final bool isPrimary;
  final int sortOrder;

  const ProductImageDto({
    required this.id,
    required this.productId,
    required this.imageUrl,
    required this.isPrimary,
    required this.sortOrder,
  });

  factory ProductImageDto.fromMap(Map<String, dynamic> map) {
    return ProductImageDto(
      id: _parseInt(map['id']),
      productId: _parseInt(map['product_id']),
      imageUrl: map['image_url'] as String,
      isPrimary: _parseBool(map['is_primary']),
      sortOrder: _parseInt(map['sort_order']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
      'sort_order': sortOrder,
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
}
