import 'package:first_vania_project/app/http/controllers/auth_controller.dart';
import 'package:first_vania_project/app/http/controllers/file_controller.dart';
import 'package:first_vania_project/app/http/middleware/authenticate.dart';
import 'package:first_vania_project/app/http/middleware/inject_user_middleware.dart';
import 'package:first_vania_project/app/http/middleware/throttle_middleware.dart';
import 'package:vania/route.dart';

void authRoutes() {
  final auth = AuthController();
  final file = FileController();

  // Public auth routes
  Router.group(() {
    Router.post('/register', auth.register).middleware([
      ThrottleMiddleware(maxAttempts: 3, duration: Duration(minutes: 1)),
    ]);

    Router.post('/login', auth.login).middleware([
      ThrottleMiddleware(maxAttempts: 3, duration: Duration(minutes: 1)),
    ]);

    Router.post('/forgot-password', auth.forgotPassword).middleware([
      ThrottleMiddleware(
        maxAttempts: 1,
        duration: Duration(minutes: 5),
        identifierField: 'email',
      ),
    ]);

    Router.post('/reset-password', auth.resetPassword).middleware([
      ThrottleMiddleware(
        maxAttempts: 1,
        duration: Duration(minutes: 5),
        identifierField: 'email',
      ),
    ]);
  }, prefix: 'auth');

  // Protected auth routes
  Router.group(() {
    Router.get('/profile', auth.profile);
    Router.put('/profile', auth.updateProfile);
    Router.post('/logout', auth.logout);
    Router.post('/avatar', file.uploadAvatar);
  }, prefix: 'auth', middleware: [
    AuthenticateMiddleware(),
    InjectUserMiddleware(),
  ]);
}
