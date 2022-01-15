import 'package:dio/dio.dart';
import 'package:sirka_app/core/models/build_config.dart';

class DioClient {
  DioClient({required this.buildConfig});

  BuildConfig buildConfig;

  Dio get dioClient => _dio();

  Dio _dio() {
    final options = BaseOptions(
      baseUrl: buildConfig.baseUrl,
      connectTimeout: 10000,
      receiveTimeout: 10000,
    );
    options.headers["content-type"] = "application/json";
    var dio = Dio(options);
    dio.interceptors.add(ApiInterceptors());
    return dio;
  }
}

class ApiInterceptors extends InterceptorsWrapper {
  @override
  Future<dynamic> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    print("API_URI: ${options.uri.toString()}\n"
        "API_HEADER: ${options.headers.toString()}\n"
        "API_DATA: ${options.data.toString()}");
    return handler.next(options);
  }

  @override
  Future<dynamic> onError(DioError err, ErrorInterceptorHandler handler) async {
    print("API_Error:\n${err.toString()}\nERROR_DATA:\n${err.response?.data.toString()}");
    return handler.next(err);
  }

  @override
  Future<dynamic> onResponse(Response response, ResponseInterceptorHandler handler) async {
    print("API_Response:\n$response");
    return handler.next(response);
  }
}
