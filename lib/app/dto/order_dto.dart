// GENERATED — dart run tool/generate_dto.dart
// Bu dosya otomatik üretilmiştir. Elle düzenleme yapılabilir,
// ancak --force ile yeniden üretildiğinde değişiklikler kaybolur.

class OrderDto {
  final int id;
  final int userId;
  final String orderNumber;
  final String status;
  final double subtotal;
  final double taxAmount;
  final double shippingCost;
  final double totalAmount;
  final String? shippingAddress;
  final String? shippingCity;
  final String? shippingPhone;
  final String? notes;
  final String? invoicePath;

  const OrderDto({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.status,
    required this.subtotal,
    required this.taxAmount,
    required this.shippingCost,
    required this.totalAmount,
    this.shippingAddress,
    this.shippingCity,
    this.shippingPhone,
    this.notes,
    this.invoicePath,
  });

  factory OrderDto.fromMap(Map<String, dynamic> map) {
    return OrderDto(
      id: _parseInt(map['id']),
      userId: _parseInt(map['user_id']),
      orderNumber: map['order_number'] as String,
      status: map['status'] as String,
      subtotal: _parseDouble(map['subtotal']),
      taxAmount: _parseDouble(map['tax_amount']),
      shippingCost: _parseDouble(map['shipping_cost']),
      totalAmount: _parseDouble(map['total_amount']),
      shippingAddress: map['shipping_address'] as String?,
      shippingCity: map['shipping_city'] as String?,
      shippingPhone: map['shipping_phone'] as String?,
      notes: map['notes'] as String?,
      invoicePath: map['invoice_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'order_number': orderNumber,
      'status': status,
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'shipping_cost': shippingCost,
      'total_amount': totalAmount,
      'shipping_address': shippingAddress,
      'shipping_city': shippingCity,
      'shipping_phone': shippingPhone,
      'notes': notes,
      'invoice_path': invoicePath,
    };
  }

  bool get isPending => status == 'pending';

  bool get isProcessing => status == 'processing';

  bool get isShipped => status == 'shipped';

  bool get isDelivered => status == 'delivered';

  bool get isCancelled => status == 'cancelled';

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
