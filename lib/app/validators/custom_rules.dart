import 'package:first_vania_project/app/models/user.dart';
import 'package:vania/http/request.dart';

class CustomRules {
  /// Güçlü şifre kuralı: en az 8 karakter, büyük harf, küçük harf, rakam ve özel karakter
  static CustomValidationRule strongPassword() {
    return CustomValidationRule(
      ruleName: 'strong_password',
      message: 'Password must be at least 8 characters and contain uppercase, lowercase, number, and special character',
      fn: (data, value, arguments) async {
        if (value == null || value.toString().isEmpty) return false;
        final password = value.toString();
        if (password.length < 8) return false;
        if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
        if (!RegExp(r'[a-z]').hasMatch(password)) return false;
        if (!RegExp(r'[0-9]').hasMatch(password)) return false;
        if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\/~`]').hasMatch(password)) return false;
        return true;
      },
    );
  }

  /// Telefon numarası kuralı: Türkiye formatı (05XXXXXXXXX)
  static CustomValidationRule turkishPhone() {
    return CustomValidationRule(
      ruleName: 'turkish_phone',
      message: 'Phone number must be in Turkish format (05XXXXXXXXX)',
      fn: (data, value, arguments) async {
        if (value == null || value.toString().isEmpty) return true;
        final phone = value.toString().replaceAll(RegExp(r'[\s\-()]'), '');
        return RegExp(r'^(05)\d{9}$').hasMatch(phone);
      },
    );
  }

  /// E-posta benzersizlik kuralı
  static CustomValidationRule uniqueEmail({int? excludeId}) {
    return CustomValidationRule(
      ruleName: 'unique_email',
      message: 'This email is already registered',
      fn: (data, value, arguments) async {
        if (value == null || value.toString().isEmpty) return false;
        var query = User().query.where('email', '=', value.toString());
        if (excludeId != null) {
          query = query.where('id', '!=', excludeId);
        }
        final existing = await query.first();
        return existing == null;
      },
    );
  }

  /// Slug formatı kuralı
  static CustomValidationRule slugFormat() {
    return CustomValidationRule(
      ruleName: 'slug_format',
      message: 'Slug must contain only lowercase letters, numbers, and hyphens',
      fn: (data, value, arguments) async {
        if (value == null || value.toString().isEmpty) return true;
        return RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(value.toString());
      },
    );
  }

  /// Pozitif sayı kuralı
  static CustomValidationRule positiveNumber() {
    return CustomValidationRule(
      ruleName: 'positive_number',
      message: 'Value must be a positive number',
      fn: (data, value, arguments) async {
        if (value == null) return false;
        final num? parsed = num.tryParse(value.toString());
        return parsed != null && parsed > 0;
      },
    );
  }
}
