/// Simüle edilmiş e-posta servisi.
/// Gerçek bir SMTP bağlantısı yerine konsola yazdırır.
class EmailService {
  /// Hoş geldiniz e-postası gönder
  Future<void> sendWelcomeEmail(String email, String name) async {
    print('📧 [EMAIL] Welcome email sent to $email');
    print('   Subject: Welcome to E-Commerce, $name!');
    print('   Body: Thank you for registering. Start shopping now!');
  }

  /// Şifre sıfırlama e-postası gönder
  Future<void> sendPasswordResetEmail(String email, String token) async {
    print('📧 [EMAIL] Password reset email sent to $email');
    print('   Subject: Password Reset Request');
    print('   Body: Use this token to reset your password: $token');
    print('   Link: http://localhost:8000/reset-password?token=$token&email=$email');
  }

  /// Sipariş onay e-postası gönder
  Future<void> sendOrderConfirmationEmail(String email, String orderNumber, double totalAmount) async {
    print('📧 [EMAIL] Order confirmation sent to $email');
    print('   Subject: Order #$orderNumber Confirmed');
    print('   Body: Your order of \$$totalAmount has been placed successfully.');
  }

  /// Sipariş durum güncelleme e-postası gönder
  Future<void> sendOrderStatusUpdateEmail(String email, String orderNumber, String status) async {
    print('📧 [EMAIL] Order status update sent to $email');
    print('   Subject: Order #$orderNumber Status Updated');
    print('   Body: Your order status has been updated to: $status');
  }
}
