import 'package:vania/migration.dart';

class CreatePasswordResetsTable extends Migration {
  @override
  Future<void> up() async {
    await create('password_resets', (Schema table) {
      table.id();
      table.string('email').length(255);
      table.string('token').length(255);
      table.boolean('is_used');
      table.dateTime('expires_at');
      table.timeStamps();
    });
  }

  @override
  Future<void> down() async {
    await drop('password_resets');
  }
}
