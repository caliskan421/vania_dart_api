import 'dart:io';

class FileUploadService {
  /// Public dosya kaydet (ürün resimleri)
  /// Dosyayı public/uploads dizinine taşır
  Future<String> savePublicFile(
    dynamic file,
    String subDirectory,
    int entityId,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    String extension = 'jpg';

    if (file is Map && file['extension'] != null) {
      extension = file['extension'].toString();
    }

    final filename = '${entityId}_$timestamp.$extension';
    final dirPath = 'storage/public/$subDirectory';
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Vania'nın file.move() metodu ile public dizine taşı
    if (file is Map && file['bytes'] != null) {
      final filePath = '$dirPath/$filename';
      await File(filePath).writeAsBytes(file['bytes']);
    }

    return '/$subDirectory/$filename';
  }

  /// Private dosya kaydet (faturalar, belgeler)
  /// Dosyayı storage/app dizinine kaydeder (URL ile erişilemez)
  Future<String> savePrivateFile(
    dynamic file,
    String subDirectory,
    String filename,
  ) async {
    final dirPath = 'storage/app/$subDirectory';
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    if (file is Map && file['bytes'] != null) {
      final filePath = '$dirPath/$filename';
      await File(filePath).writeAsBytes(file['bytes']);
    }

    return '$dirPath/$filename';
  }

  /// Fatura dosyasını oluştur (simüle)
  Future<String> generateInvoice(int orderId, String orderNumber) async {
    final dirPath = 'storage/app/invoices';
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final filename = 'invoice_$orderNumber.txt';
    final filePath = '$dirPath/$filename';

    // Basit bir fatura simülasyonu
    final invoiceContent = '''
========================================
              FATURA / INVOICE
========================================
Sipariş No: $orderNumber
Tarih: ${DateTime.now().toIso8601String()}
========================================
Bu bir simüle edilmiş faturadır.
========================================
''';

    await File(filePath).writeAsString(invoiceContent);
    return filePath;
  }

  /// Private dosya oku
  Future<File?> getPrivateFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  /// Dosya uzantısı kontrolü
  bool isAllowedImageExtension(String extension) {
    const allowed = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    return allowed.contains(extension.toLowerCase());
  }

  /// Dosya uzantısı kontrolü (belgeler)
  bool isAllowedDocumentExtension(String extension) {
    const allowed = ['pdf', 'doc', 'docx', 'txt'];
    return allowed.contains(extension.toLowerCase());
  }
}
