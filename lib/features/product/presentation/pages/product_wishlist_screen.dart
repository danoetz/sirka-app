import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sirka_app/core/constants/db.dart';
import 'package:sirka_app/features/product/data/models/product.dart';
import 'package:sirka_app/features/product/presentation/bloc/product_cubit.dart';
import 'package:sirka_app/features/product/presentation/bloc/wishlist_cubit.dart';
import 'package:sirka_app/features/product/presentation/widgets/empty_wishlist.dart';
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
  ProductCubit? productBloc;
  late Box<Product> productBox;

  @override
  void initState() {
    bloc = BlocProvider.of<WishlistCubit>(context);
    productBloc = BlocProvider.of<ProductCubit>(context);
    productBox = Hive.box<Product>(Db.PRODUCTS);
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      initData();
    });
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
        title: const Text("Wishlist"),
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
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Get.back();
                                  await bloc!.clearWishlist();
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
          printDebug("ERROR");
          DialogHelper.showErrorDialog(title: "INFORMATION", description: state.message);
        } else if (state is WishlistLoading) {
          printDebug("LOADING");
        } else if (state is WishlistLoaded) {
          printDebug("LOADED ${state.products!.length} wishlists");
          bloc!.productsWishlist.addAll(state.products!);
        } else if (state is RemoveFromWishlist) {
          printDebug("REMOVED");
        } else if (state is ClearWishlist) {
          printDebug("CLEAR");
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
      // read from product list
      printDebug("FROM PRODUCT LIST");
      return const EmptyWishlist();
    } else {
      return ValueListenableBuilder(
        valueListenable: productBox.listenable(),
        builder: (context, Box<Product> box, child) {
          List<Product> db = box.values.toList();
          List<Product> products = db.where((x) => x.isWishlist!).toList();

          if (products.isEmpty) {
            // read from database
            printDebug("FROM DATABASE");
            return const EmptyWishlist();
          }
          return Obx(() {
            return LazyLoadScrollView(
              onEndOfPage: () {
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
                itemCount: products.length,
                itemBuilder: (context, index) {
                  Product data = products[index];
                  Product product = db.singleWhere((x) => x.id == data.id! && x.isWishlist!);

                  return Column(
                    children: [
                      InkWell(
                        onTap: () => productBloc!.openDetail(product: product),
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
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
                                        placeholder: (context, url) {
                                          return SizedBox(
                                            height: Get.width / 3,
                                            width: Get.width / 3,
                                            child: Shimmer.fromColors(
                                              baseColor: Colors.grey,
                                              highlightColor: Colors.white54,
                                              child: Container(
                                                color: Colors.white54,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(product.name!, style: AppTextStyle.text18sbBlack),
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
                                  child: const Icon(Icons.favorite_outlined, color: Colors.red),
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
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Get.back();
                                              bloc!.removeFromWishlist(product: product);
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
                      index == (products.length - 1) && bloc!.isLoading.value
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
}
