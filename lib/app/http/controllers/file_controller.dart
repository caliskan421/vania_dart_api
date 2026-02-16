import 'package:first_vania_project/app/models/order.dart';
import 'package:first_vania_project/app/services/file_upload_service.dart';
import 'package:vania/authentication.dart';
import 'package:vania/http/controller.dart';
import 'package:vania/http/request.dart';
import 'package:vania/http/response.dart';

class FileController extends Controller {
  final FileUploadService _fileService = FileUploadService();

  int? _authUserId() {
    final rawUserId = Auth().user()['id'];
    if (rawUserId == null) return null;
    if (rawUserId is int) return rawUserId;
    if (rawUserId is num) return rawUserId.toInt();
    return int.tryParse(rawUserId.toString());
  }

  /// GET /api/v1/files/invoices/{orderNumber}
  /// Kullanıcının kendi faturasını indirmesini sağlar (private storage)
  Future<Response> downloadInvoice(Request request, dynamic orderNumber) async {
    try {
      final userId = _authUserId();
      if (userId == null) {
        return Response.json({
          'success': false,
          'message': 'Authentication required',
        }, 401);
      }

      // Siparişin bu kullanıcıya ait olduğunu kontrol et
      final order = await Order().query.where('order_number', '=', orderNumber.toString()).where('user_id', '=', userId).first();

      if (order == null) {
        return Response.json({
          'success': false,
          'message': 'Order not found',
        }, 404);
      }

      final invoicePath = order['invoice_path']?.toString();
      if (invoicePath == null || invoicePath.isEmpty) {
        return Response.json({
          'success': false,
          'message': 'Invoice not available for this order',
        }, 404);
      }

      final file = await _fileService.getPrivateFile(invoicePath);
      if (file == null) {
        return Response.json({
          'success': false,
          'message': 'Invoice file not found',
        }, 404);
      }

      final content = await file.readAsString();
      return Response.json({
        'success': true,
        'data': {
          'order_number': orderNumber,
          'invoice_content': content,
          'filename': 'invoice_$orderNumber.txt',
        },
      }, 200);
    } catch (e) {
      return Response.json({
        'success': false,
        'message': 'Failed to download invoice',
      }, 500);
    }
  }

  /// POST /api/v1/auth/avatar
  /// Kullanıcı profil resmi yükle
  Future<Response> uploadAvatar(Request request) async {
    try {
      final userId = _authUserId();
      if (userId == null) {
        return Response.json({
          'success': false,
          'message': 'Authentication required',
        }, 401);
      }

      final file = request.file('avatar');
      if (file == null) {
        return Response.json({
          'success': false,
          'message': 'Avatar file is required',
        }, 422);
      }

      final extension = file.extension;
      if (!_fileService.isAllowedImageExtension(extension)) {
        return Response.json({
          'success': false,
          'message': 'Invalid file type. Allowed: jpg, jpeg, png, gif, webp',
        }, 422);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'avatar_${userId}_$timestamp.$extension';
      await file.move(toPath: 'public/avatars', name: filename);
      final avatarUrl = '/avatars/$filename';

      return Response.json({
        'success': true,
        'message': 'Avatar uploaded successfully',
        'data': {
          'avatar_url': avatarUrl,
        },
      }, 200);
    } catch (e) {
      return Response.json({
        'success': false,
        'message': 'Failed to upload avatar',
      }, 500);
    }
  }
}
