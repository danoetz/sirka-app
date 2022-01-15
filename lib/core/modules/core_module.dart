import 'package:sirka_app/core/models/build_config.dart';
import 'package:sirka_app/core/modules/locator_module.dart';

class CoreModule {
  static Future<void> init({required BuildConfig Function() buildConfig}) async {
    locator.registerFactory(() => buildConfig());
  }
}
