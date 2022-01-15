import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sirka_app/core/constants/db.dart';
import 'package:sirka_app/features/product/data/models/product.dart';

class HiveModule {
  static Future<void> init() async {
    var appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);

    Hive.registerAdapter(ProductAdapter());
    await Hive.openBox<Product>(Db.PRODUCTS);
  }
}
