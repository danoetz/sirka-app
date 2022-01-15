import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

logD(dynamic data) {
  var logger = Logger();
  logger.d(data);
}

logE(dynamic data) {
  var logger = Logger();
  logger.e(data);
}

logI(dynamic data) {
  var logger = Logger();
  logger.i(data);
}

logW(dynamic data) {
  var logger = Logger();
  logger.w(data);
}

logV(dynamic data) {
  var logger = Logger();
  logger.v(data);
}

printDebug(dynamic data) {
  // ignore: avoid_print
  if (kDebugMode) print("[DEBUG] $data");
}
