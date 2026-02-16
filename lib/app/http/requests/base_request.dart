import 'package:vania/http/request.dart';
import 'package:vania/vania.dart';

/// Tüm request sınıfları için temel sınıf.
/// Alt sınıflar rules() ve messages() metodlarını override eder.
abstract class BaseRequest {
  /// Validation kuralları
  Map<String, String> rules();

  /// Özel hata mesajları
  Map<String, String> messages() => {};

  /// Custom validation kuralları (opsiyonel)
  List<CustomValidationRule> customRules() => [];

  /// Request'i doğrula
  Future<void> validate(Request request) async {
    final customRuleList = customRules();
    if (customRuleList.isNotEmpty) {
      await request
          .setCustomRule(customRuleList)
          .validate(rules(), messages());
    } else {
      await request.validate(rules(), messages());
    }
  }
}
