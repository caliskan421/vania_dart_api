import 'package:vania/migration.dart';

class CreatePersonalAccesTokensTable extends Migration {
  @override
  Future<void> up() async {
    await create('personal_access_tokens', (Schema table) {
      table.id();
      table.string("name");
      table.bigInt("tokenable_id");
      table.string("token");
      table.timeStamps();
      table.dateTime("last_used_at").nullable();
      table.softDeletes();
    });
  }

  @override
  Future<void> down() async {
    await drop('personal_access_tokens');
  }
}
