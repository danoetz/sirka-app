import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:sirka_app/core/network/network_info.dart';
import 'package:sirka_app/features/product/data/repositories/product_repository_impl.dart';

GetIt sl = GetIt.instance;

class LocatorModule {
  static void init() {
    sl.registerFactory(() => NetworkInfoImpl(InternetConnectionChecker()));
    sl.registerFactory(() => ProductRepositoryImpl());
  }
}
