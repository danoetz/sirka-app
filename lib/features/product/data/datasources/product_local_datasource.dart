import 'package:hive/hive.dart';
import 'package:sirka_app/core/constants/db.dart';
import 'package:sirka_app/features/product/data/models/product.dart';
import 'package:sirka_app/shared/helpers/print_helper.dart';

abstract class ProductLocalDataSource {
  Future<List<Product>> getProductsPagination({int page, int limit});
  Future<void> cacheProducts(List<Product>? products, int limit);
  Future<List<Product>> getWishlist();
  Future<bool> addWishlist(Product? product);
  Future<bool> removeWishlist(Product? product);
  Future<void> clearWishlist();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  @override
  Future<List<Product>> getProductsPagination({int page = 0, int limit = 5}) async {
    try {
      logW("""
        PAGE: $page
        LIMIT: $limit
        RANGE: ${page * limit} - ${(page * limit) + limit}""");
      Box<Product> box = await Hive.openBox<Product>(Db.PRODUCTS);
      int total = box.values.length;
      if (((page * limit) + limit) > total) {
        return box.values.toList().sublist(page * limit);
      } else {
        return box.values.toList().sublist(page * limit, (page * limit) + limit);
      }
    } catch (e) {
      logE("getProductsPagination: ${e.toString()}");
      rethrow;
    }
  }

  @override
  Future<void> cacheProducts(List<Product>? products, int limit) async {
    try {
      Box<Product> box = await Hive.openBox<Product>(Db.PRODUCTS);

      if (box.isNotEmpty) {
        // check wishlist
        for (var i in products!) {
          bool isExist = box.containsKey(i.id);
          // keep wishlist
          if (isExist) {
            Product b = box.values.singleWhere((x) => x.id == i.id);
            i.isWishlist = b.isWishlist;
          }
          box.put(i.id!, i);
        }
      } else {
        // box empty
        for (var i in products!) {
          i.isWishlist = false;
          box.put(i.id!, i);
        }
      }
    } catch (e) {
      logE("cacheProducts: ${e.toString()}");
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

  @override
  Future<void> clearWishlist() async {
    try {
      Box<Product> box = await Hive.openBox<Product>(Db.PRODUCTS);
      for (var i in box.values) {
        i.isWishlist = false;
        box.put(i.id, i);
      }
    } catch (e) {
      logE("clearWishlist: ${e.toString()}");
      rethrow;
    }
  }
}
