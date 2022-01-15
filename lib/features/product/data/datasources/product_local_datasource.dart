import 'package:hive/hive.dart';
import 'package:sirka_app/core/constants/db.dart';
import 'package:sirka_app/features/product/data/models/product.dart';
import 'package:sirka_app/shared/helpers/print_helper.dart';

abstract class ProductLocalDataSource {
  Future<List<Product>> getProducts();
  Future<void> cacheProducts(List<Product>? products);
  Future<void> updateProduct(Product? product);
  Future<List<Product>> getWishlist();
  Future<bool> addWishlist(Product? product);
  Future<bool> removeWishlist(Product? product);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  @override
  Future<List<Product>> getProducts() async {
    try {
      Box<Product> box = await Hive.openBox<Product>(Db.PRODUCTS);
      return box.values.toList();
    } catch (e) {
      logE("getProducts: ${e.toString()}");
      rethrow;
    }
  }

  @override
  Future<void> cacheProducts(List<Product>? products) async {
    try {
      Box<Product> box = await Hive.openBox<Product>(Db.PRODUCTS);
      // box.clear();
      for (var i in products!) {
        box.put(i.id!, i);
      }
    } catch (e) {
      logE("cacheProducts: ${e.toString()}");
      rethrow;
    }
  }

  @override
  Future<void> updateProduct(Product? product) async {
    try {
      Box<Product> box = await Hive.openBox<Product>(Db.PRODUCTS);
      box.put(product!.id!, product);
    } catch (e) {
      logE("updateProduct: ${e.toString()}");
      rethrow;
    }
  }

  @override
  Future<List<Product>> getWishlist() async {
    try {
      Box<Product> box = await Hive.openBox<Product>(Db.PRODUCTS);
      List<Product> list = box.values.where((x) => x.isWishlist == true).toList();
      return list;
    } catch (e) {
      logE("getWishlist: ${e.toString()}");
      rethrow;
    }
  }

  @override
  Future<bool> addWishlist(Product? product) async {
    try {
      Box<Product> box = await Hive.openBox<Product>(Db.PRODUCTS);
      product!.isWishlist = true;
      await box.put(product.id!, product);
      return true;
    } catch (e) {
      logE("addWishlist: ${e.toString()}");
      return false;
    }
  }

  @override
  Future<bool> removeWishlist(Product? product) async {
    try {
      Box<Product> box = await Hive.openBox<Product>(Db.PRODUCTS);
      product!.isWishlist = false;
      await box.put(product.id!, product);
      return true;
    } catch (e) {
      logE("removeWishlist: ${e.toString()}");
      return false;
    }
  }
}
