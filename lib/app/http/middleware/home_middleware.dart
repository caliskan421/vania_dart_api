import 'package:vania/http/middleware.dart';
import 'package:vania/http/request.dart';

class HomeMiddleware extends Middleware {
  @override
  handle(Request req) async {
    if (req.headers['app_header'] == 'my_value') {
      print("BEFORE: founded...");
    }
  }
}
