import 'package:first_vania_project/app/http/controllers/file_controller.dart';
import 'package:first_vania_project/app/http/controllers/order_controller.dart';
import 'package:first_vania_project/app/http/middleware/authenticate.dart';
import 'package:first_vania_project/app/http/middleware/inject_user_middleware.dart';
import 'package:first_vania_project/app/http/middleware/throttle_middleware.dart';
import 'package:vania/route.dart';

void orderRoutes() {
  final order = OrderController();
  final file = FileController();

  Router.group(() {
    Router.post('/orders', order.store).middleware([
      ThrottleMiddleware(maxAttempts: 10, duration: Duration(minutes: 1)),
    ]);
    Router.get('/orders', order.index);
    Router.get('/orders/{id}', order.show);

    // Fatura indirme (private storage)
    Router.get('/files/invoices/{orderNumber}', file.downloadInvoice);
  }, middleware: [
    AuthenticateMiddleware(),
    InjectUserMiddleware(),
  ]);
}
