import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:sirka_app/core/network/network_info.dart';

GetIt locator = GetIt.instance;

class LocatorModule {
  static void init() {
    locator.registerFactory(() => NetworkInfoImpl(InternetConnectionChecker()));
  }
}
