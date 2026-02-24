/// DTO otomatik üretimi için alan tipi ve şema tanımları.
///
/// Kullanım:
/// ```dart
/// class Product extends Model with DtoSchema {
///   @override
///   List<FieldDef> get schema => [
///     FieldDef('name',           FieldType.string),
///     FieldDef('price',          FieldType.double_),
///     FieldDef('discount_price', FieldType.double_, nullable: true),
///   ];
/// }
/// ```
///
/// DTO üretmek için:
///   dart run tool/generate_dto.dart
///   dart run tool/generate_dto.dart --watch
///   dart run tool/generate_dto.dart --force
library;

/// Desteklenen alan tipleri (Dart / SQL karşılıkları)
enum FieldType {
  integer, // int
  bigInteger, // int (bigint)
  double_, // double
  string, // String
  boolean, // bool
  dateTime, // DateTime
  json, // Map<String, dynamic>
}

/// Tek bir alanın tanımı
class FieldDef {
  final String name; // snake_case — DB sütun adı
  final FieldType type;
  final bool nullable;

  const FieldDef(this.name, this.type, {this.nullable = false});

  /// Dart tip adı (nullable ise sona `?` eklenir)
  String get dartType {
    final base = switch (type) {
      FieldType.integer => 'int',
      FieldType.bigInteger => 'int',
      FieldType.double_ => 'double',
      FieldType.string => 'String',
      FieldType.boolean => 'bool',
      FieldType.dateTime => 'DateTime',
      FieldType.json => 'Map<String, dynamic>',
    };
    return nullable ? '$base?' : base;
  }

  /// camelCase alan adı — DTO property adı olarak kullanılır
  /// Örn: `discount_price` → `discountPrice`
  String get camelName {
    final parts = name.split('_');
    return parts.first + parts.skip(1).map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join();
  }
}

/// Model sınıflarına eklenen mixin.
/// [schema] override edilerek alan tanımları belirtilir.
/// `fillable` listesi schema'dan otomatik türetilir.
/// fillable override etsen mixin'i ezerdin — ama artık gerek yok, schema tek kaynak of truth.
///
/// NOT: fillable getter'ı mutlaka cache'lenmiş (aynı referanslı) bir liste döndürmeli.
/// Vania'nın _validateFieldsForAssignment metodu fillable listesine .add() ile
/// created_at/updated_at/deleted_at ekler. Eğer getter her çağrıda yeni liste döndürürse
/// bu eklemeler kaybolur ve insert/update işlemleri InvalidArgumentException fırlatır.
mixin DtoSchema {
  List<FieldDef> get schema;

  List<String>? _fillableCache;

  List<String> get fillable {
    _fillableCache ??= schema.map((f) => f.name).toList();
    return _fillableCache!;
  }
}

/// [Sorun]: fillable getter'ı her çağrıda schema.map((f) => f.name).toList() ile yeni bir liste oluşturuyordu.
/// Vania framework'ün _validateFieldsForAssignment metodu ise bu listeye .add() ile created_at, updated_at, deleted_at eklemeye çalışıyordu.
/// Ama getter her seferinde yeni liste döndürdüğü için bu eklemeler kayboluyordu. Sonuç: insert/update verilerinde created_at veya updated_at bulunan her istek
/// InvalidArgumentException fırlatıyordu.
/// [Düzeltme]: _fillableCache ile liste cache'lendi. Artık Vania'nın .add() çağrıları kalıcı.
