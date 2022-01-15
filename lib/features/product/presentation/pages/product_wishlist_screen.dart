import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:sirka_app/core/routers/app_names.dart';
import 'package:sirka_app/features/product/data/models/product.dart';
import 'package:sirka_app/features/product/presentation/bloc/wishlist_cubit.dart';
import 'package:sirka_app/shared/helpers/dialog_helper.dart';
import 'package:sirka_app/shared/helpers/print_helper.dart';
import 'package:sirka_app/shared/styles/text_styles.dart';

class ProductWishlistScreen extends StatefulWidget {
  const ProductWishlistScreen({Key? key}) : super(key: key);

  @override
  State<ProductWishlistScreen> createState() => _ProductWishlistScreenState();
}

class _ProductWishlistScreenState extends State<ProductWishlistScreen> {
  WishlistCubit? bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<WishlistCubit>(context);
    initData();
    super.initState();
  }

  initData() async {
    bloc!.productsWishlist.clear();
    await bloc!.getWishlistProducts(page: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: InkWell(
          onTap: () => bloc!.getWishlistProducts(page: 0),
          child: const Text("Wishlist"),
        ),
        centerTitle: true,
      ),
      body: buildBlocListener(),
    );
  }

  BlocListener<WishlistCubit, WishlistState> buildBlocListener() {
    return BlocListener(
      listener: (context, state) {
        if (state is WishlistError) {
          print("ERROR");
          DialogHelper.hideLoading();
          DialogHelper.showErrorDialog(title: "INFORMATION", description: state.message);
        } else if (state is WishlistLoading) {
          print("LOADING");
          DialogHelper.showLoading(message: state.message!);
        } else if (state is WishlistLoaded) {
          print("LOADED ${state.products!.length} wishlists");
          bloc!.productsWishlist.addAll(state.products!);
          DialogHelper.hideLoading();
        } else if (state is RemoveFromWishlist) {
          print("REMOVE");
        } else if (state is ClearWishlist) {
          print("CLEAR");
        }
      },
      child: buildContent(),
    );
  }

  Widget buildContent() {
    return Obx(() {
      return LazyLoadScrollView(
        onEndOfPage: () {
          printDebug("FETCH NEXT PAGE | IS LAST PAGE: ${bloc!.isLastPage.value}");
          int nextPage = bloc!.pageController.value + 1;
          if (!(bloc!.isLastPage.value)) {
            bloc!.getWishlistProducts(page: nextPage);
          }
        },
        isLoading: bloc!.isLoading.value,
        scrollDirection: Axis.vertical,
        scrollOffset: 100,
        child: ListView.separated(
          separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1),
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: bloc!.productsWishlist.length,
          itemBuilder: (context, index) {
            Product product = bloc!.productsWishlist[index];
            return Column(
              children: [
                InkWell(
                  onTap: () => Get.toNamed(AppPagesName.PRODUCT_DETAIL, arguments: <String, dynamic>{"product": product, "hero": "wishlist-${product.id}"}),
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    // color: index.isEven ? Colors.grey : Colors.lime,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.zero),
                    ),
                    child: Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: Get.width / 3,
                              width: Get.width / 3,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Hero(
                                tag: "wishlist-${product.id}",
                                child: CachedNetworkImage(
                                  imageUrl: product.image!,
                                  fit: BoxFit.cover,
                                  cacheKey: "wishlist-${product.id}",
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${product.id!} - ${product.name!}", style: AppTextStyle.text18sbBlack),
                                    Text(
                                      product.description!,
                                      softWrap: true,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text("\$ ${product.price!}", style: AppTextStyle.text14sbBlack),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: InkWell(
                            child: const Icon(Icons.favorite_outlined),
                            onTap: () async => await bloc!.removeFromWishlist(product: product),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // index == (bloc!.productsWishlist.length - 1) && bloc!.isLoading.value ? const CircularProgressIndicator() : const SizedBox(),
                index == (bloc!.productsWishlist.length - 1) && bloc!.isLoading.value ? const CircularProgressIndicator() : const SizedBox(),
              ],
            );
          },
        ),
      );
    });
  }
}
