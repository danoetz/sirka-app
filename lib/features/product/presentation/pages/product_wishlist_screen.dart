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
import 'package:sirka_app/shared/helpers/snackbar_helper.dart';
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
        actions: [
          Obx(() {
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: bloc!.productsWishlist.isNotEmpty
                  ? GestureDetector(
                      child: const Icon(Icons.delete_forever),
                      onTap: () async {
                        await showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Are you sure?'),
                            content: const Text('Remove all products from wishlist?'),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Get.back(),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await bloc!.clearWishlist();
                                  Get.back();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : const SizedBox(),
            );
          }),
        ],
      ),
      body: buildBlocListener(),
    );
  }

  BlocListener<WishlistCubit, WishlistState> buildBlocListener() {
    return BlocListener(
      listener: (context, state) {
        if (state is WishlistError) {
          print("ERROR");
          DialogHelper.showErrorDialog(title: "INFORMATION", description: state.message);
        } else if (state is WishlistLoading) {
          print("LOADING");
        } else if (state is WishlistLoaded) {
          print("LOADED ${state.products!.length} wishlists");
          bloc!.productsWishlist.addAll(state.products!);
        } else if (state is RemoveFromWishlist) {
          print("REMOVE");
          SnackBarHelper.dismissSnackBar();
          SnackBarHelper.showSnackBar(title: "Wishlist", description: state.message);
        } else if (state is ClearWishlist) {
          print("CLEAR");
        }
      },
      child: Obx(() {
        return buildContent();
      }),
    );
  }

  Widget buildContent() {
    if (bloc!.productsWishlist.isEmpty && bloc!.isLoading.value) {
      return const Center(
        child: SizedBox(
          height: 32,
          width: 32,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else if (bloc!.productsWishlist.isEmpty) {
      return const Center(
        child: Text("Add a product to wishlist"),
      );
    } else {
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
                  onTap: () => Get.toNamed(
                    AppPagesName.PRODUCT_DETAIL,
                    arguments: <String, dynamic>{"product": product, "hero": "hero-${product.id}"},
                  ),
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
                                tag: "hero-${product.id}",
                                child: CachedNetworkImage(
                                  imageUrl: product.image!,
                                  fit: BoxFit.cover,
                                  cacheKey: "hero-${product.id}",
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
                            onTap: () async {
                              await showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Are you sure?'),
                                  content: const Text('Remove product from wishlist?'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () => Get.back(),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await bloc!.removeFromWishlist(product: product);
                                        Get.back();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                index == (bloc!.productsWishlist.length - 1) && bloc!.isLoading.value
                    ? const SizedBox(
                        height: 32,
                        width: 32,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const SizedBox(),
              ],
            );
          },
        ),
      );
    }
  }
}
