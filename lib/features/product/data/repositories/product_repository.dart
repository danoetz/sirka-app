import 'package:sirka_app/core/models/pagination.dart';
import 'package:sirka_app/features/product/data/models/product.dart';

abstract class ProductRepository {
  Future<List<Product>?> fetchProductsPagination({int page, int limit});
  Future<List<Product>?> getWishlist();
  Future<Pagination<Product>> getWishlistPagination({int currentPage, int perPage});
  Future<bool> addWishlist(Product? product);
  Future<bool> removeWishlist(Product? product);
  Future<void> clearWishlist();
}
