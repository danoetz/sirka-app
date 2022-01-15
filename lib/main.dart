import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:sirka_app/core/constants/config.dart';
import 'package:sirka_app/core/models/build_config.dart';
import 'package:sirka_app/core/modules/core_module.dart';
import 'package:sirka_app/core/routers/app_pages.dart';
import 'package:sirka_app/features/splash_screen/presentation/pages/splash_screen.dart';
import 'package:sirka_app/shared/helpers/print_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  BlocOverrides.runZoned(
    () async {
      await CoreModule.init(
        buildConfig: () => BuildConfig(baseUrl: Config.baseUrl, debug: Config.isDebug),
      );
      runApp(const MyApp());
    },
    blocObserver: CubitObserver(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SIRKA',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
      getPages: AppPages.pages,
    );
  }
}

class CubitObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    printDebug('onCreate -- ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    printDebug('onChange -- ${bloc.runtimeType}, $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    printDebug('onError -- ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    printDebug('onClose -- ${bloc.runtimeType}');
  }
}
