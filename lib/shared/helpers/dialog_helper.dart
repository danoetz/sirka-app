import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirka_app/shared/styles/text_styles.dart';

class DialogHelper {
  //show error dialog
  static void showErrorDialog({String title = 'Error', String? description = 'Something went wrong'}) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTextStyle.text18sbBlack),
              const SizedBox(height: 10),
              Text(description ?? '', style: AppTextStyle.text14sbBlack),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (Get.isDialogOpen!) Get.back();
                },
                child: const Text('Okay'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //show loading
  static void showLoading({String? message}) {
    Get.dialog(
      Dialog(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: 70,
          color: Colors.amber,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              Text(message ?? 'Loading...'),
            ],
          ),
        ),
        insetPadding: EdgeInsets.zero,
      ),
      barrierDismissible: false,
    );
  }

  //hide loading
  static void hideLoading() {
    if (Get.isDialogOpen!) Get.back();
  }
}
