import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:sirka_app/core/models/pagination.dart';
import 'package:sirka_app/core/modules/locator_module.dart';
import 'package:sirka_app/features/product/data/models/product.dart';
import 'package:sirka_app/features/product/data/repositories/product_repository_impl.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(ProductInitial());

  RxList<Product> productsList = <Product>[].obs;
  // RxList<Product> productsWishlist = <Product>[].obs;
  Rx<int> pageController = 0.obs;
  // Rx<int> wishlistPageController = 0.obs;
  static const int defaultPerPage = 10;
  // Rx<int> startController = 0.obs;
  // Rx<int> endController = 0.obs;
  RxBool isLastPage = false.obs;
  RxBool isLoading = false.obs;

  Future<void> initProductsData() async {
    await locator<ProductRepositoryImpl>().fetchProducts();
  }

  Future<Pagination<Product>?> getProducts({required int page, int perPage = defaultPerPage}) async {
    try {
      emit(ProductLoading());
      isLoading.value = true;
      final pagination = await locator<ProductRepositoryImpl>().getProductsPagination(currentPage: page, perPage: perPage);

      if (pagination.data.isNotEmpty) {
        pageController.value = page;
        List<Product> res = pagination.data;
        if (res.length < defaultPerPage) {
          isLastPage.value = true;
        }
        emit(ProductLoaded(products: res));
      } else {
        emit(ProductError(message: "All products has been loaded!"));
      }
      isLoading.value = false;
      return pagination;
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> refreshProducts() async {
    try {
      emit(ReloadingData());
      productsList.clear();
      isLastPage.value = false;
      pageController.value = 0;
      isLoading.value = true;

      final pagination = await locator<ProductRepositoryImpl>().getProductsPagination(currentPage: 0, perPage: defaultPerPage);

      if (pagination.data.isNotEmpty) {
        List<Product> res = pagination.data;
        emit(ProductLoaded(products: res));
      } else {
        emit(ProductError(message: "All products has been loaded!"));
      }
      isLoading.value = false;
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> updateProductWishlist({required Product product}) async {
    try {
      if (product.isWishlist! == false || product.isWishlist == null) {
        await locator<ProductRepositoryImpl>().addWishlist(product);
        emit(WishlistAdded(product: product));
      } else {
        await locator<ProductRepositoryImpl>().removeWishlist(product);
        emit(WishlistRemoved(product: product));
      }
    } catch (e) {
      emit(WishlistError(message: e.toString()));
    }
  }
}