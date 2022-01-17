import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:sirka_app/core/network/dio_client.dart';

import 'locator_module.dart';

late Dio dio;

class DioModule {
  static void init() {
    sl.registerSingleton(DioClient(buildConfig: GetIt.I()));
    dio = GetIt.I<DioClient>().dioClient;
  }
}
