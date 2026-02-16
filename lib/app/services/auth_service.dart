import 'dart:math';
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

    final user = await User().query.where('email', '=', data['email']).first();

    await _emailService.sendWelcomeEmail(data['email'].toString(), data['name'].toString());

    return _sanitizeUser(user!);
  }

  /// Kullanıcı girişi ve token oluşturma
  Future<Map<String, dynamic>> login(String email, String password) async {
    final user = await User().query.where('email', '=', email).first();

    if (user == null) {
      throw Exception('User not found');
    }

    if (!Hash().verify(password, user['password'])) {
      throw Exception('Invalid credentials');
    }

    final auth = Auth().login(user);
    final token = await auth.createToken(
      expiresIn: Duration(hours: 24),
    );

    return {
      'user': _sanitizeUser(user),
      'token': token,
      'token_type': 'Bearer',
      'expires_in': 86400,
    };
  }

  /// Şifre sıfırlama talebi (simüle)
  Future<void> forgotPassword(String email) async {
    final user = await User().query.where('email', '=', email).first();

    if (user == null) {
      throw Exception('User not found with this email');
    }

    // Rastgele token oluştur
    final token = _generateResetToken();

    // Eski tokenları geçersiz kıl
    await PasswordReset()
        .query
        .where('email', '=', email)
        .where('is_used', '=', false)
        .update({'is_used': true, 'updated_at': DateTime.now().toIso8601String()});

    // Yeni reset kaydı oluştur
    await PasswordReset().query.insert({
      'email': email,
      'token': token,
      'is_used': false,
      'expires_at': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    await _emailService.sendPasswordResetEmail(email, token);
  }

  /// Şifre sıfırlama işlemi
  Future<void> resetPassword(String email, String token, String newPassword) async {
    final resetRecord = await PasswordReset().query.where('email', '=', email).where('token', '=', token).where('is_used', '=', false).first();

    if (resetRecord == null) {
      throw Exception('Invalid or expired reset token');
    }

    // Token süresini kontrol et
    final expiresAt = DateTime.parse(resetRecord['expires_at'].toString());
    if (DateTime.now().isAfter(expiresAt)) {
      throw Exception('Reset token has expired');
    }

    // Şifreyi güncelle
    final hashedPassword = Hash().make(newPassword);
    await User().query.where('email', '=', email).update({
      'password': hashedPassword,
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Token'ı kullanılmış olarak işaretle
    await PasswordReset().query.where('id', '=', resetRecord['id']).update({'is_used': true, 'updated_at': DateTime.now().toIso8601String()});
  }

  /// Rastgele reset token'ı oluştur
  String _generateResetToken() {
    final random = Random.secure();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(64, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Kullanıcı verisinden hassas alanları temizle
  Map<String, dynamic> _sanitizeUser(Map<String, dynamic> user) {
    return {
      'id': user['id'],
      'name': user['name'],
      'email': user['email'],
      'phone': user['phone'],
      'role': user['role'],
      'avatar_url': user['avatar_url'],
      'address': user['address'],
      'created_at': user['created_at']?.toString(),
    };
  }
}
