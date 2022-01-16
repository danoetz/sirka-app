import 'package:sirka_app/core/constants/endpoint.dart';
import 'package:sirka_app/core/modules/dio_module.dart';
import 'package:sirka_app/features/product/data/models/product.dart';
import 'package:sirka_app/shared/helpers/print_helper.dart';

abstract class ProductRemoteDataSource {
  Future<List<Product>?> getProductsPagination({int page, int limit});
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  @override
  Future<List<Product>?> getProductsPagination({int page = 0, int limit = 5}) async {
    try {
      // API provide page number start from 1
      final result = await dio.get("${Api.products}?page=${page + 1}&limit=$limit");
      if (result.statusCode == 200 && result.data != null) {
        return List<Product>.from(result.data.map((x) => Product.fromJson(x)));
      } else {
        return null;
      }
    } catch (e) {
      logE(e);
      rethrow;
    }
  }
}
