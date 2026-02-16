import 'package:vania/migration.dart';

class CreateProductImagesTable extends Migration {
  @override
  Future<void> up() async {
    await create('product_images', (Schema table) {
      table.id();
      table.bigInt('product_id').unsigned();
      table.string('image_url').length(500);
      table.boolean('is_primary');
      table.integer('sort_order');
      table.timeStamps();
      table.foreign('product_id', 'products', 'id',
          constrained: true, onDelete: 'CASCADE');
    });
  }

  @override
  Future<void> down() async {
    await drop('product_images');
  }
}
