// GENERATED — dart run tool/generate_dto.dart
// Bu dosya otomatik üretilmiştir. Elle düzenleme yapılabilir,
// ancak --force ile yeniden üretildiğinde değişiklikler kaybolur.

class ProductDto {
  final int id;
  final int categoryId;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final double? discountPrice;
  final int stock;
  final String sku;
  final bool isActive;

  const ProductDto({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    this.discountPrice,
    required this.stock,
    required this.sku,
    required this.isActive,
  });

  factory ProductDto.fromMap(Map<String, dynamic> map) {
    return ProductDto(
      id: _parseInt(map['id']),
      categoryId: _parseInt(map['category_id']),
      name: map['name'] as String,
      slug: map['slug'] as String,
      description: map['description'] as String?,
      price: _parseDouble(map['price']),
      discountPrice: map['discount_price'] != null ? _parseDouble(map['discount_price']) : null,
      stock: _parseInt(map['stock']),
      sku: map['sku'] as String,
      isActive: _parseBool(map['is_active']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'stock': stock,
      'sku': sku,
      'is_active': isActive,
    };
  }

  double get effectivePrice => discountPrice ?? price;

  /// Stokta var mı?
  bool get inStock => stock > 0;

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
