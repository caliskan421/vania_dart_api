import 'package:vania/migration.dart';

class CreateOrdersTable extends Migration {
  @override
  Future<void> up() async {
    await create('orders', (Schema table) {
      table.id();
      table.bigInt('user_id').unsigned();
      table.string('order_number').length(50);
      table.string('status').length(30); // pending, processing, shipped, delivered, cancelled
      table.decimal('subtotal', precision: 10, scale: 2);
      table.decimal('tax_amount', precision: 10, scale: 2);
      table.decimal('shipping_cost', precision: 10, scale: 2);
      table.decimal('total_amount', precision: 10, scale: 2);
      table.text('shipping_address');
      table.string('shipping_city').length(100);
      table.string('shipping_phone').length(20);
      table.text('notes').nullable();
      table.string('invoice_path').length(500).nullable();
      table.timeStamps();
      table.softDeletes();
      table.foreign('user_id', 'users', 'id', constrained: true, onDelete: 'CASCADE');
    });
  }

  @override
  Future<void> down() async {
    await drop('orders');
  }
}
