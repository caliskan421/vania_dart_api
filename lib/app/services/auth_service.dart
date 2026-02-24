import 'dart:math';
import 'package:first_vania_project/app/dto/user_dto.dart';
import 'package:first_vania_project/app/models/password_reset.dart';
import 'package:first_vania_project/app/models/user.dart';
import 'package:first_vania_project/app/services/email_service.dart';
import 'package:vania/authentication.dart';
import 'package:vania/vania.dart';

class AuthService {
  final EmailService _emailService = EmailService();

  /// Yeni kullanıcı kaydı
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final password = Hash().make(data['password'].toString());

    final userData = {
      'name': data['name'],
      'email': data['email'],
      'password': password,
      'phone': data['phone'],
      'role': 'user',
      'avatar_url': null,
      'address': null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await User().query.insert(userData);

    final user = await User().findByEmail(data['email'].toString());

    await _emailService.sendWelcomeEmail(data['email'].toString(), data['name'].toString());

    return user!.toSanitizedMap();
  }

  /// Kullanıcı girişi
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Auth().login() raw Map bekler, bu yüzden ham map'i de tutuyoruz
    final userMap = await User().query.where('email', '=', email).first();

    if (userMap == null) {
      throw Exception('User not found with this email');
    }

    final user = UserDto.fromMap(userMap);

    if (!Hash().verify(password, user.password ?? '')) {
      throw Exception('Invalid password');
    }

    final auth = Auth().login(userMap);
    final token = await auth.createToken(
      expiresIn: Duration(hours: 24),
    );

    return {
      'user': user.toSanitizedMap(),
      'token': token,
      'token_type': 'Bearer',
      'expires_in': 86400,
    };
  }

  /// E-posta doğrulama kodu üreterek [resetPassword]a bırakır
  Future<void> forgotPassword(String email) async {
    final user = await User().findByEmail(email);

    if (user == null) {
      throw Exception('User not found with this email');
    }

    final verifyCode = _generateResetCode();

    // Eski tokenları geçersiz kıl
    await PasswordReset().query.where('email', '=', email).where('is_used', '=', false).update({
      'is_used': true,
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Yeni reset kaydı oluştur
    await PasswordReset().query.insert({
      'email': email,
      'token': verifyCode,
      'is_used': false,
      'expires_at': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    await _emailService.sendPasswordResetEmail(email, verifyCode);
  }

  /// Şifre sıfırlama işlemi
  Future<void> resetPassword(String email, String token, String newPassword) async {
    final resetRecord = await PasswordReset().findActiveByEmail(email);

    if (resetRecord == null) {
      throw Exception('Invalid or expired reset token');
    }

    if (!Hash().verify(token, resetRecord.token)) {
      throw Exception('Invalid or expired reset token');
    }

    if (resetRecord.isExpired) {
      throw Exception('Reset token has expired');
    }

    final hashedPassword = Hash().make(newPassword);
    await User().query.where('email', '=', email).update({
      'password': hashedPassword,
      'updated_at': DateTime.now().toIso8601String(),
    });

    await PasswordReset().query.where('id', '=', resetRecord.id).update({
      'is_used': true,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Şifre sıfırlama token'ını üretir.
  String _generateResetCode() {
    final random = Random.secure();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(64, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
