import 'package:first_vania_project/app/http/controllers/cart_controller.dart';
import 'package:first_vania_project/app/http/middleware/authenticate.dart';
import 'package:first_vania_project/app/http/middleware/inject_user_middleware.dart';
import 'package:vania/route.dart';

void cartRoutes() {
  final cart = CartController();

  Router.group(() {
    Router.get('/cart', cart.index);
    Router.post('/cart/items', cart.addItem);
    Router.put('/cart/items/{id}', cart.updateItem);
    Router.delete('/cart/items/{id}', cart.removeItem);
    Router.delete('/cart', cart.clear);
  }, middleware: [
    AuthenticateMiddleware(),
    InjectUserMiddleware(),
  ]);
}
