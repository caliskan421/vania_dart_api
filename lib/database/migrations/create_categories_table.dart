import 'package:vania/migration.dart';

class CreateCategoriesTable extends Migration {
  @override
  Future<void> up() async {
    await create('categories', (Schema table) {
      table.id();
      table.string('name').length(100);
      table.string('slug').length(120);
      table.text('description').nullable();
      table.string('image_url').length(500).nullable();
      table.boolean('is_active');
      table.timeStamps();
    });
  }

  @override
  Future<void> down() async {
    await drop('categories');
  }
}
