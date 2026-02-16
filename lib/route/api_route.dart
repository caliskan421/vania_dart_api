import 'package:first_vania_project/app/http/controllers/category_controller.dart';
import 'package:first_vania_project/app/http/controllers/product_controller.dart';
import 'package:first_vania_project/route/routes/admin_routes.dart';
import 'package:first_vania_project/route/routes/auth_routes.dart';
import 'package:first_vania_project/route/routes/cart_routes.dart';
import 'package:first_vania_project/route/routes/order_routes.dart';
import 'package:vania/route.dart';

class ApiRoute extends Route {
  @override
  String prefix = 'api/v1';

  @override
  void register() {
    super.register();

    final product = ProductController();
    final category = CategoryController();

    // Sub-routes
    authRoutes();
    cartRoutes();
    orderRoutes();
    adminRoutes();

    // Public: Ürünler & Kategoriler
    Router.get('/products', product.index);
    Router.get('/products/{id}', product.show);
    Router.get('/categories', category.index);
    Router.get('/categories/{id}', category.show);
  }
}
