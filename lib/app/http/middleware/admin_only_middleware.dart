import 'package:vania/authentication.dart';
import 'package:vania/http/middleware.dart';
import 'package:vania/http/request.dart';
import 'package:vania/vania.dart' show abort;

/// Admin yetkisi gerektiren route'lar için middleware.
/// Kullanıcının role alanının 'admin' olmasını kontrol eder.
class AdminOnlyMiddleware extends Middleware {
  @override
  Future handle(Request req) async {
    try {
      final user = Auth().user();

      if (user['role'] != 'admin') {
        abort(403, 'Access denied. Admin privileges required.');
      }
    } catch (e) {
      abort(401, 'Authentication required');
    }
  }
}
