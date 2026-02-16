import 'package:first_vania_project/app/http/controllers/admin_controller.dart';
import 'package:first_vania_project/app/http/controllers/category_controller.dart';
import 'package:first_vania_project/app/http/controllers/product_controller.dart';
import 'package:first_vania_project/app/http/middleware/admin_only_middleware.dart';
import 'package:first_vania_project/app/http/middleware/authenticate.dart';
import 'package:first_vania_project/app/http/middleware/inject_user_middleware.dart';
import 'package:vania/route.dart';

void adminRoutes() {
  final product = ProductController();
  final category = CategoryController();
  final admin = AdminController();

  Router.group(() {
    // Ürün Yönetimi
    Router.post('/products', product.store);
    Router.put('/products/{id}', product.update);
    Router.delete('/products/{id}', product.destroy);
    Router.post('/products/{id}/images', product.uploadImages);

    // Kategori Yönetimi
    Router.post('/categories', category.store);
    Router.put('/categories/{id}', category.update);
    Router.delete('/categories/{id}', category.destroy);

    // Kullanıcı Yönetimi
    Router.get('/users', admin.listUsers);
    Router.get('/users/{id}', admin.showUser);
    Router.delete('/users/{id}', admin.deleteUser);

    // Sipariş Yönetimi
    Router.get('/orders', admin.listOrders);
    Router.put('/orders/{id}/status', admin.updateOrderStatus);

    // Analitik
    Router.get('/analytics', admin.analytics);
  },
      prefix: 'admin',
      middleware: [
        AuthenticateMiddleware(),
        InjectUserMiddleware(),
        AdminOnlyMiddleware(),
      ]);
}
