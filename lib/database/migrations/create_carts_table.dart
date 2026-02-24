import 'package:vania/migration.dart';

class CreateCartsTable extends Migration {
  @override
  Future<void> up() async {
    await create('carts', (Schema table) {
      table.id();
      table.bigInt('user_id').unsigned();
      table.timeStamps();
      table.foreign('user_id', 'users', 'id', constrained: true, onDelete: 'CASCADE');
    });
  }

  @override
  Future<void> down() async {
    await drop('carts');
  }
}
