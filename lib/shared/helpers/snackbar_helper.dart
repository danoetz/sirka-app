import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackBarHelper {
  // show SnackBar
  static void showSnackBar({String? title, String? description}) {
    Get.snackbar(
      title ?? "INFO",
      description ?? "",
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 500),
    );
  }

  // dismiss SnackBar
  static void dismissSnackBar() {
    Get.closeCurrentSnackbar();
  }
}
