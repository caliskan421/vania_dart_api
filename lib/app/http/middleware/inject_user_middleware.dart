import 'package:vania/authentication.dart';
import 'package:vania/http/middleware.dart';
import 'package:vania/http/request.dart';

/// Kimliği doğrulanmış kullanıcının bilgilerini request'e enjekte eder.
/// Controller'ların user_id'ye güvenli şekilde erişmesini sağlar.
class InjectUserMiddleware extends Middleware {
  @override
  Future handle(Request req) async {
    try {
      final user = Auth().user();
      req.merge({
        'auth_user_id': user['id'],
        'auth_user_role': user['role'],
        'auth_user_email': user['email'],
      });
    } catch (e) {
      // Auth yoksa devam et (public route'larda kullanılabilir)
    }
  }
}
