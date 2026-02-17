// tool/generate_dto.dart — DtoSchema tabanlı DTO üretici
//
// Kullanım:
//   dart run tool/generate_dto.dart           → tek seferlik üretim
//   dart run tool/generate_dto.dart --watch   → dosya değişikliğinde otomatik üret
//   dart run tool/generate_dto.dart --force   → mevcut DTO'ları da yeniden üret

import 'dart:io';

void main(List<String> args) async {
  final watch = args.contains('--watch');
  final force = args.contains('--force');

  await _generate(force: force);

  if (watch) {
    _info('Watch modu aktif — lib/app/models/ izleniyor...');
    Directory('lib/app/models')
        .watch(events: FileSystemEvent.all)
        .where((e) => e.path.endsWith('.dart'))
        .listen((_) => _generate(force: force));
    await Future.delayed(const Duration(days: 365));
  }
}

// ─── Ana üretim akışı ────────────────────────────────────────

Future<void> _generate({bool force = false}) async {
  final modelsDir = Directory('lib/app/models');
  final dtoDir = Directory('lib/app/dto');

  if (!modelsDir.existsSync()) {
    _err('lib/app/models/ bulunamadı.');
    return;
  }
  dtoDir.createSync(recursive: true);

  final modelFiles = modelsDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  int created = 0, skipped = 0, errors = 0;

  for (final file in modelFiles) {
    final modelName = _fileBaseName(file.path);
    final dtoFile = File('lib/app/dto/${modelName}_dto.dart');

    if (dtoFile.existsSync() && !force) {
      skipped++;
      continue;
    }

    try {
      final content = file.readAsStringSync();

      if (!content.contains('DtoSchema')) {
        _warn('$modelName — DtoSchema mixin yok, atlandı.');
        continue;
      }

      final fields = _parseSchema(content);
      if (fields.isEmpty) {
        _warn('$modelName — schema alanları parse edilemedi.');
        errors++;
        continue;
      }

      final className = _toPascalCase(modelName);
      dtoFile.writeAsStringSync(_buildDtoSource(className, fields));
      _ok('${dtoFile.path}  (${className}Dto · ${fields.length} alan)');
      created++;
    } catch (e) {
      _err('$modelName: $e');
      errors++;
    }
  }

  _info('$created oluşturuldu · $skipped mevcut · $errors hata');
}

// ─── Schema parse (regex ile FieldDef listesini okur) ─────────

class _Field {
  final String name; // snake_case
  final String type; // FieldType enum adı (integer, string, double_, ...)
  final bool nullable;

  _Field(this.name, this.type, this.nullable);

  String get camelName {
    final parts = name.split('_');
    return parts.first +
        parts
            .skip(1)
            .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
            .join();
  }

  String get dartType {
    final base = switch (type) {
      'integer' || 'bigInteger' => 'int',
      'double_' => 'double',
      'string' => 'String',
      'boolean' => 'bool',
      'dateTime' => 'DateTime',
      'json' => 'Map<String, dynamic>',
      _ => 'dynamic',
    };
    return nullable ? '$base?' : base;
  }

  String get baseDartType => dartType.replaceAll('?', '');
}

List<_Field> _parseSchema(String content) {
  // schema getter'ının [...] bloğunu yakala
  final blockMatch = RegExp(
    r'List<FieldDef>\s+get\s+schema\s*=>\s*\[([^\]]+)\]',
    dotAll: true,
  ).firstMatch(content);
  if (blockMatch == null) return [];

  final block = blockMatch.group(1)!;

  // Her FieldDef(...) çağrısını parse et
  return RegExp(
    r"""FieldDef\s*\(\s*'(\w+)'\s*,\s*FieldType\.(\w+)"""
    r"""(?:\s*,\s*nullable\s*:\s*(true|false))?\s*\)""",
  ).allMatches(block).map((m) {
    return _Field(m.group(1)!, m.group(2)!, m.group(3) == 'true');
  }).toList();
}

// ─── DTO kaynak kodu üretimi ──────────────────────────────────

String _buildDtoSource(String className, List<_Field> fields) {
  // id alanını başa ekle
  final all = [_Field('id', 'integer', false), ...fields];

  // Hangi yardımcı metotlara ihtiyaç var?
  final helpers = <String>{};

  final buf = StringBuffer()
    ..writeln('// GENERATED — dart run tool/generate_dto.dart')
    ..writeln('// Bu dosya otomatik üretilmiştir. Elle düzenleme yapılabilir,')
    ..writeln('// ancak --force ile yeniden üretildiğinde değişiklikler kaybolur.')
    ..writeln()
    ..writeln('class ${className}Dto {');

  // Alan tanımları
  for (final f in all) {
    buf.writeln('  final ${f.dartType} ${f.camelName};');
  }

  // Constructor
  buf
    ..writeln()
    ..writeln('  const ${className}Dto({');
  for (final f in all) {
    buf.writeln(f.nullable
        ? '    this.${f.camelName},'
        : '    required this.${f.camelName},');
  }
  buf.writeln('  });');

  // fromMap factory
  buf
    ..writeln()
    ..writeln('  factory ${className}Dto.fromMap(Map<String, dynamic> map) {')
    ..writeln('    return ${className}Dto(');
  for (final f in all) {
    buf.writeln("      ${f.camelName}: ${_fromMapExpr(f, helpers)},");
  }
  buf
    ..writeln('    );')
    ..writeln('  }');

  // toMap
  buf
    ..writeln()
    ..writeln('  Map<String, dynamic> toMap() {')
    ..writeln('    return {');
  for (final f in all) {
    buf.writeln("      '${f.name}': ${_toMapExpr(f)},");
  }
  buf
    ..writeln('    };')
    ..writeln('  }');

  // Otomatik computed getter: effectivePrice
  final names = fields.map((f) => f.name).toSet();
  if (names.contains('price') && names.contains('discount_price')) {
    buf
      ..writeln()
      ..writeln(
          '  double get effectivePrice => discountPrice ?? price;');
  }

  // Yardımcı metotlar (ihtiyaç duyulanlara göre)
  if (helpers.contains('parseBool')) {
    buf.writeln(_helperParseBool);
  }
  if (helpers.contains('parseInt')) {
    buf.writeln(_helperParseInt);
  }
  if (helpers.contains('parseDouble')) {
    buf.writeln(_helperParseDouble);
  }

  buf.writeln('}');
  return buf.toString();
}

// ─── fromMap ifade üretimi ────────────────────────────────────

String _fromMapExpr(_Field f, Set<String> helpers) {
  final key = "map['${f.name}']";

  if (f.type == 'boolean') {
    helpers.add('parseBool');
    return f.nullable ? '$key != null ? _parseBool($key) : null' : '_parseBool($key)';
  }

  if (f.nullable) {
    return switch (f.type) {
      'integer' || 'bigInteger' => () {
          helpers.add('parseInt');
          return '$key != null ? _parseInt($key) : null';
        }(),
      'double_' => () {
          helpers.add('parseDouble');
          return '$key != null ? _parseDouble($key) : null';
        }(),
      'dateTime' =>
        '$key != null ? DateTime.parse($key.toString()) : null',
      'json' => '$key as Map<String, dynamic>?',
      _ => '$key as String?',
    };
  }

  return switch (f.type) {
    'integer' || 'bigInteger' => () {
        helpers.add('parseInt');
        return '_parseInt($key)';
      }(),
    'double_' => () {
        helpers.add('parseDouble');
        return '_parseDouble($key)';
      }(),
    'dateTime' => 'DateTime.parse($key.toString())',
    'json' => '$key as Map<String, dynamic>',
    _ => '$key as String',
  };
}

// ─── toMap ifade üretimi ──────────────────────────────────────

String _toMapExpr(_Field f) {
  final val = f.camelName;
  return switch (f.type) {
    'dateTime' => f.nullable ? '$val?.toIso8601String()' : '$val.toIso8601String()',
    _ => val,
  };
}

// ─── Yardımcı metot şablonları ────────────────────────────────

const _helperParseBool = '''
  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v == 1;
    final s = v.toString().trim().toLowerCase();
    return s == '1' || s == 'true';
  }''';

const _helperParseInt = '''
  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }''';

const _helperParseDouble = '''
  static double _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }''';

// ─── Küçük yardımcılar ───────────────────────────────────────

String _fileBaseName(String path) =>
    path.split(Platform.pathSeparator).last.replaceAll('.dart', '');

String _toPascalCase(String snake) =>
    snake.split('_').map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join();

void _ok(String m) => stdout.writeln('\x1B[32m  + $m\x1B[0m');
void _warn(String m) => stdout.writeln('\x1B[33m  ~ $m\x1B[0m');
void _err(String m) => stderr.writeln('\x1B[31m  ! $m\x1B[0m');
void _info(String m) => stdout.writeln('\x1B[36m  $m\x1B[0m');
