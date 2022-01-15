import 'package:flutter/foundation.dart';

class Config {
  static const String baseUrl = "https://61da8de74593510017aff588.mockapi.io/api/$apiVersion";
  static const String apiVersion = "v1";
  static const bool isDebug = kDebugMode ? true : false;
}
