import 'dart:io';
import 'package:vania/migration.dart';
import 'package:first_vania_project/database/migrations/create_user_table.dart';
import 'package:first_vania_project/database/migrations/create_personal_acces_tokens_table.dart';
import 'package:first_vania_project/database/migrations/create_categories_table.dart';
import 'package:first_vania_project/database/migrations/create_products_table.dart';
import 'package:first_vania_project/database/migrations/create_product_images_table.dart';
import 'package:first_vania_project/database/migrations/create_carts_table.dart';
import 'package:first_vania_project/database/migrations/create_cart_items_table.dart';
import 'package:first_vania_project/database/migrations/create_orders_table.dart';
import 'package:first_vania_project/database/migrations/create_order_items_table.dart';
import 'package:first_vania_project/database/migrations/create_password_resets_table.dart';
import '../../config/database.dart';

void main(List<String> args) async {
  try {
    await MigrationConnection().setup(database);
    await MigrationRunner().migrationRegister([
      // Core tables
      CreateUserTable(),
      CreatePersonalAccesTokensTable(),

      // E-Commerce tables
      CreateCategoriesTable(),
      CreateProductsTable(),
      CreateProductImagesTable(),
      CreateCartsTable(),
      CreateCartItemsTable(),
      CreateOrdersTable(),
      CreateOrderItemsTable(),
      CreatePasswordResetsTable(),
    ]).run(args);
    await MigrationConnection().connection?.close();
  } catch (e) {
    print('Migration failed: $e');
    exit(0);
  } finally {
    exit(0);
  }
}
