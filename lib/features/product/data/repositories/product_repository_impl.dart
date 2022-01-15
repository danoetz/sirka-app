import 'package:sirka_app/core/models/pagination.dart';
import 'package:sirka_app/core/modules/locator_module.dart';
import 'package:sirka_app/core/network/network_info.dart';
import 'package:sirka_app/features/product/data/datasources/product_local_datasource.dart';
import 'package:sirka_app/features/product/data/datasources/product_remote_datasource.dart';
import 'package:sirka_app/features/product/data/models/product.dart';
import 'package:sirka_app/features/product/data/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<List<Product>?> fetchProducts() async {
    bool isOnline = await locator.get<NetworkInfoImpl>().isConnected;
    if (isOnline) {
      // fetch from remote
      var res = await ProductRemoteDataSourceImpl().getProducts();
      // cache & return data
      await ProductLocalDataSourceImpl().cacheProducts(res);
      var result = await ProductLocalDataSourceImpl().getProducts();
      return result;
    } else {
      // fetch from local
      return await ProductLocalDataSourceImpl().getProducts();
    }
  }

  @override
  Future<List<Product>?> fetchProductsPagination({int page = 0, int limit = 5}) async {
    bool isOnline = await locator.get<NetworkInfoImpl>().isConnected;
    if (isOnline) {
      // fetch from remote
      var res = await ProductRemoteDataSourceImpl().getProductsPagination(page: page, limit: limit);
      // cache & return data
      await ProductLocalDataSourceImpl().cacheProducts(res);
      var result = await ProductLocalDataSourceImpl().getProductsPagination(page: page, limit: limit);
      return result;
    } else {
      // fetch from local
      return await ProductLocalDataSourceImpl().getProductsPagination(page: page, limit: limit);
    }
  }

  @override
  Future<List<Product>?> getProducts() async {
    return await ProductLocalDataSourceImpl().getProducts();
  }

  @override
  Future<Pagination<Product>> getProductsPagination({int currentPage = 0, int perPage = 5}) async {
    List<Product>? data = await getProducts();

    int total = data!.length;
    List<Product> list = [];
    Pagination<Product> pagination;

    // for (var i in data) {
    //   print("${i.id} - ${i.name}");
    // }

    if (currentPage < (total / perPage).ceil()) {
      if (((currentPage * perPage) + perPage) > total) {
        List<Product> a = data.sublist(currentPage * perPage);
        list.addAll(a);
      } else {
        List<Product> a = data.sublist(currentPage * perPage, (currentPage * perPage) + perPage);
        list.addAll(a);
      }

      pagination = Pagination<Product>(
        currentPage: currentPage,
        perPage: perPage,
        lastPage: (total / perPage).ceil(),
        total: total,
        data: list,
      );
    } else {
      pagination = Pagination<Product>(
        currentPage: currentPage,
        perPage: perPage,
        lastPage: (total / perPage).ceil(),
        total: total,
        data: [],
      );
    }
    return pagination;
  }

  @override
  Future<List<Product>?> getWishlist() async {
    return await ProductLocalDataSourceImpl().getWishlist();
  }

  @override
  Future<Pagination<Product>> getWishlistPagination({int currentPage = 0, int perPage = 5}) async {
    List<Product>? data = await getWishlist();

    int total = data!.length;
    List<Product> list = [];
    Pagination<Product> pagination;

    if (currentPage < (total / perPage).ceil()) {
      if (((currentPage * perPage) + perPage) > total) {
        List<Product> a = data.sublist(currentPage * perPage);
        list.addAll(a);
      } else {
        List<Product> a = data.sublist(currentPage * perPage, (currentPage * perPage) + perPage);
        list.addAll(a);
      }

      pagination = Pagination<Product>(
        currentPage: currentPage,
        perPage: perPage,
        lastPage: (total / perPage).ceil(),
        total: total,
        data: list,
      );
    } else {
      pagination = Pagination<Product>(
        currentPage: currentPage,
        perPage: perPage,
        lastPage: (total / perPage).ceil(),
        total: total,
        data: [],
      );
    }
    return pagination;
  }

  @override
  Future<bool> addWishlist(Product? product) async {
    return await ProductLocalDataSourceImpl().addWishlist(product);
  }

  @override
  Future<bool> removeWishlist(Product? product) async {
    return await ProductLocalDataSourceImpl().removeWishlist(product);
  }
}
