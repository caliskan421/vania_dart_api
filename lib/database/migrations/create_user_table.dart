import 'package:vania/migration.dart';

class CreateUserTable extends Migration {
  @override
  Future<void> up() async {
    await create('users', (Schema table) {
      table.id();
      table.string('name').length(100);
      table.string('email').length(255);
      table.string('password').length(255);
      table.string('phone').length(20).nullable();
      table.string('role').length(20); // user, admin
      table.string('avatar_url').length(500).nullable();
      table.text('address').nullable();
      table.timeStamps();
      table.softDeletes();
    });
  }

  @override
  Future<void> down() async {
    await drop('users');
  }
}
