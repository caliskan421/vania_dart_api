import 'package:vania/migration.dart';

class CreateCartItemsTable extends Migration {
  @override
  Future<void> up() async {
    await create('cart_items', (Schema table) {
      table.id();
      table.bigInt('cart_id').unsigned();
      table.bigInt('product_id').unsigned();
      table.integer('quantity');
      table.decimal('unit_price', precision: 10, scale: 2);
      table.timeStamps();
      table.foreign('cart_id', 'carts', 'id',
          constrained: true, onDelete: 'CASCADE');
      table.foreign('product_id', 'products', 'id',
          constrained: true, onDelete: 'CASCADE');
    });
  }

  @override
  Future<void> down() async {
    await drop('cart_items');
  }
}
