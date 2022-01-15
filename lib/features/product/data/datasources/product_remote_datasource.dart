import 'package:sirka_app/core/constants/endpoint.dart';
import 'package:sirka_app/core/modules/dio_module.dart';
import 'package:sirka_app/features/product/data/models/product.dart';
import 'package:sirka_app/shared/helpers/print_helper.dart';

abstract class ProductRemoteDataSource {
  Future<List<Product>?> getProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  @override
  Future<List<Product>?> getProducts() async {
    try {
      final result = await dio.get(Api.products);
      if (result.statusCode == 200 && result.data != null) {
        return List<Product>.from(result.data.map((x) => Product.fromJson(x)));
      } else {
        return null;
      }
    } catch (e) {
      logE(e);
    }
  }
}
