import 'package:vania/migration.dart';

class CreateProductsTable extends Migration {
  @override
  Future<void> up() async {
    await create('products', (Schema table) {
      table.id();
      table.bigInt('category_id').unsigned().nullable();
      table.string('name').length(255);
      table.string('slug').length(280);
      table.text('description').nullable();
      table.decimal('price', precision: 10, scale: 2);
      table.decimal('discount_price', precision: 10, scale: 2).nullable();
      table.integer('stock');
      table.string('sku').length(100).nullable();
      table.boolean('is_active');
      table.timeStamps();
      table.softDeletes();
      table.foreign('category_id', 'categories', 'id',
          constrained: true, onDelete: 'SET NULL');
    });
  }

  @override
  Future<void> down() async {
    await drop('products');
  }
}
