import 'package:vania/migration.dart';

class CreateOrderItemsTable extends Migration {
  @override
  Future<void> up() async {
    await create('order_items', (Schema table) {
      table.id();
      table.bigInt('order_id').unsigned();
      table.bigInt('product_id').unsigned();
      table.string('product_name').length(255);
      table.integer('quantity');
      table.decimal('unit_price', precision: 10, scale: 2);
      table.decimal('total_price', precision: 10, scale: 2);
      table.timeStamps();
      table.foreign('order_id', 'orders', 'id',
          constrained: true, onDelete: 'CASCADE');
      table.foreign('product_id', 'products', 'id',
          constrained: true, onDelete: 'CASCADE');
    });
  }

  @override
  Future<void> down() async {
    await drop('order_items');
  }
}
