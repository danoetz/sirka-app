import 'package:sirka_app/core/models/build_config.dart';
import 'package:sirka_app/core/modules/dio_module.dart';
import 'package:sirka_app/core/modules/hive_module.dart';
import 'package:sirka_app/core/modules/locator_module.dart';

class CoreModule {
  static Future<void> init({required BuildConfig Function() buildConfig}) async {
    sl.registerFactory(() => buildConfig());
    await loadModules();
  }

  static Future<void> loadModules() async {
    await HiveModule.init();
    DioModule.init();
    LocatorModule.init();
  }
}
