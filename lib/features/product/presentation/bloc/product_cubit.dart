import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:sirka_app/core/modules/locator_module.dart';
import 'package:sirka_app/core/routers/app_names.dart';
import 'package:sirka_app/features/product/data/models/product.dart';
import 'package:sirka_app/features/product/data/repositories/product_repository_impl.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(ProductInitial());

  RxList<Product> productsList = <Product>[].obs;
  Rx<int> pageController = 0.obs;
  static const int defaultPerPage = 10;
  RxBool isLastPage = false.obs;
  RxBool isLoading = false.obs;
  Rx<Product> productDetail = Product().obs;

  Future<void> getProductsPagination({required int page, int perPage = defaultPerPage}) async {
    try {
      emit(ProductLoading());
      isLoading.value = true;
      final data = await locator<ProductRepositoryImpl>().fetchProductsPagination(page: page, limit: perPage);

      pageController.value = page;
      if (data!.length < defaultPerPage) {
        isLastPage.value = true;
      }
      emit(ProductLoaded(products: data));
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> refreshProducts() async {
    productsList.clear();
    isLastPage.value = false;
    pageController.value = 0;

    getProductsPagination(page: 0, perPage: defaultPerPage);
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
      emit(ProductError(message: e.toString()));
    }
  }

  openDetail({Product? product}) {
    productDetail.value = product!;
    emit(ProductDetailLoaded(product: product));
    Get.toNamed(AppPagesName.PRODUCT_DETAIL);
  }
}
