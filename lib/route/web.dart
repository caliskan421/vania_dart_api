import 'package:vania/http/response.dart' show Response;
import 'package:vania/route.dart';

/// Web sayfa UI'ları
class WebRoute extends Route {
  @override
  void register() {
    super.register();
    Router.get("/", () {
      return Response.html('<span>BISMILLAH - Flutter Vania</span>');
    });
  }
}
