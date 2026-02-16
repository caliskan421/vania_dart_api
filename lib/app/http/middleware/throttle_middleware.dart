import 'package:vania/http/middleware.dart';
import 'package:vania/http/request.dart';
import 'package:vania/vania.dart' show abort;

/// In-memory rate limiter deposu
class _ThrottleStore {
  static final Map<String, List<DateTime>> _attempts = {};

  static void recordAttempt(String key) {
    _attempts.putIfAbsent(key, () => []);
    _attempts[key]!.add(DateTime.now());
  }

  static int getAttemptCount(String key, Duration window) {
    if (!_attempts.containsKey(key)) return 0;

    final cutoff = DateTime.now().subtract(window);
    _attempts[key]!.removeWhere((time) => time.isBefore(cutoff));
    return _attempts[key]!.length;
  }

  static void cleanup() {
    final now = DateTime.now();
    _attempts.removeWhere((key, attempts) {
      attempts.removeWhere((time) => now.difference(time) > Duration(hours: 2));
      return attempts.isEmpty;
    });
  }
}

/// Rate limiting middleware.
/// [maxAttempts] - izin verilen maksimum istek sayısı
/// [duration] - zaman penceresi
class ThrottleMiddleware extends Middleware {
  final int maxAttempts;
  final Duration duration;
  final String? identifierField;
  final bool includePathInKey;

  ThrottleMiddleware({
    required this.maxAttempts,
    required this.duration,
    this.identifierField,
    this.includePathInKey = true,
  });

  @override
  Future handle(Request req) async {
    _ThrottleStore.cleanup();

    String identifier;
    if (identifierField != null) {
      final rawValue = req.input(identifierField!);
      if (rawValue == null || rawValue.toString().trim().isEmpty) {
        abort(422, '$identifierField is required for rate limiting.');
      }
      identifier = rawValue.toString().trim().toLowerCase();
    } else {
      identifier = req.ip ?? 'unknown';
    }

    final path = includePathInKey ? req.uri.path : '';
    final key = '$identifier:$path';

    final attempts = _ThrottleStore.getAttemptCount(key, duration);

    if (attempts >= maxAttempts) {
      abort(429, 'Too many requests. Please try again later.');
    }

    _ThrottleStore.recordAttempt(key);
  }
}
