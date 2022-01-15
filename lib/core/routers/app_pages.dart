// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:sirka_app/features/product/presentation/pages/product_detail_screen.dart';
import 'package:sirka_app/features/product/presentation/pages/product_list_screen.dart';
import 'package:sirka_app/features/splash_screen/presentation/pages/splash_screen.dart';

import 'app_names.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppPagesName.SPLASH_SCREEN, page: () => const SplashScreen()),
    GetPage(name: AppPagesName.PRODUCT_LIST, page: () => const ProductListScreen()),
    GetPage(name: AppPagesName.PRODUCT_DETAIL, page: () => const ProductDetailScreen()),
  ];
}
