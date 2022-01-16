import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:sirka_app/core/constants/db.dart';
import 'package:sirka_app/core/routers/app_names.dart';
import 'package:sirka_app/features/product/data/models/product.dart';
import 'package:sirka_app/features/product/presentation/bloc/product_cubit.dart';
import 'package:sirka_app/shared/helpers/dialog_helper.dart';
import 'package:sirka_app/shared/helpers/print_helper.dart';
import 'package:sirka_app/shared/helpers/snackbar_helper.dart';
import 'package:sirka_app/shared/styles/text_styles.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  ProductCubit? bloc;
  late Box<Product> productBox;

  @override
  void initState() {
    bloc = BlocProvider.of<ProductCubit>(context);
    initData();
    productBox = Hive.box<Product>(Db.PRODUCTS);
    super.initState();
  }

  initData() async {
    bloc!.productsList.clear();
    await bloc!.getProductsPagination(page: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Product List"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              child: const Icon(Icons.favorite_outlined),
              onTap: () => Get.toNamed(AppPagesName.PRODUCT_WISHLIST),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              child: const Icon(Icons.refresh),
              onTap: () async => await bloc!.refreshProducts(),
            ),
          ),
        ],
      ),
      body: buildBlocListener(),
    );
  }

  BlocListener<ProductCubit, ProductState> buildBlocListener() {
    return BlocListener(
      listener: (context, state) {
        if (state is ProductError) {
          printDebug("ERROR");
          DialogHelper.showErrorDialog(title: "INFORMATION", description: state.message);
        } else if (state is ProductLoading) {
          printDebug("LOADING");
        } else if (state is ProductLoaded) {
          printDebug("LOADED");
          bloc!.productsList.addAll(state.products!);
        } else if (state is WishlistAdded) {
          printDebug("ADDED");
          SnackBarHelper.dismissSnackBar();
          SnackBarHelper.showSnackBar(
            title: "Wishlist",
            description: "${state.product!.name} is added to wishlist",
          );
        } else if (state is WishlistRemoved) {
          printDebug("REMOVED");
          SnackBarHelper.dismissSnackBar();
          SnackBarHelper.showSnackBar(
            title: "Wishlist",
            description: "${state.product!.name} is removed from wishlist",
          );
        }
      },
      child: Obx(() {
        return buildContent();
      }),
    );
  }

  Widget buildContent() {
    if (bloc!.productsList.isEmpty && bloc!.isLoading.value) {
      return const Center(
        child: SizedBox(
          height: 32,
          width: 32,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else if (bloc!.productsList.isEmpty) {
      return const Center(
        child: Text("Not found"),
      );
    } else {
      return ValueListenableBuilder(
        valueListenable: productBox.listenable(),
        builder: (context, Box<Product> box, child) {
          List<Product> db = box.values.toList();
          return Obx(() {
            return LazyLoadScrollView(
              onEndOfPage: () {
                int nextPage = bloc!.pageController.value + 1;
                if (!(bloc!.isLastPage.value)) {
                  bloc!.getProductsPagination(page: nextPage);
                }
              },
              isLoading: bloc!.isLoading.value,
              scrollDirection: Axis.vertical,
              scrollOffset: 100,
              child: ListView.separated(
                separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1),
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: bloc!.productsList.length,
                itemBuilder: (context, index) {
                  Product product = bloc!.productsList[index];
                  bool wishlistStatus = db.singleWhere((x) => x.id == product.id!).isWishlist!;

                  return Column(
                    children: [
                      InkWell(
                        onTap: () => Get.toNamed(AppPagesName.PRODUCT_DETAIL, arguments: <String, dynamic>{"product": product, "hero": "hero-${product.id}"}),
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
                                  child: SizedBox(child: wishlistStatus ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border)),
                                  onTap: () async {
                                    await bloc!.updateProductWishlist(product: product);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      index == (bloc!.productsList.length - 1) && bloc!.isLoading.value
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
          });
        },
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
