import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:sirka_app/core/modules/locator_module.dart';
import 'package:sirka_app/features/product/data/models/product.dart';
import 'package:sirka_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:sirka_app/shared/helpers/print_helper.dart';

part 'wishlist_state.dart';

class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit() : super(WishlistInitial());

  RxList<Product> productsWishlist = <Product>[].obs;
  Rx<int> pageController = 0.obs;
  Rx<int> wishlistPageController = 0.obs;
  static const int defaultPerPage = 10;
  RxBool isLastPage = false.obs;
  RxBool isLoading = false.obs;

  Future<void> getWishlistProducts({required int page, int perPage = defaultPerPage}) async {
    try {
      isLoading.value = true;
      emit(WishlistLoading());
      logW(page);
      final pagination = await locator<ProductRepositoryImpl>().getWishlistPagination(currentPage: page, perPage: perPage);

      pageController.value = page;
      List<Product> res = pagination.data;
      if (res.length < defaultPerPage) {
        isLastPage.value = true;
      }
      isLoading.value = false;
      emit(WishlistLoaded(products: res));
    } catch (e) {
      emit(WishlistError(message: e.toString()));
      logE("RESPONSE_WISHLIST_ERROR: ${e.toString()}");
    }
  }

  Future<void> removeFromWishlist({required Product product}) async {
    try {
      emit(WishlistLoading());
      bool isUpdated = await locator<ProductRepositoryImpl>().removeWishlist(product);
      if (isUpdated) {
        productsWishlist.remove(product);
        emit(WishlistError(message: "Product has been removed from wishlist"));
      } else {
        emit(WishlistError(message: "Failed to remove product!"));
      }
    } catch (e) {
      emit(WishlistError(message: e.toString()));
      logE("REMOVE_WISHLIST_ERROR: ${e.toString()}");
    }
  }
}
