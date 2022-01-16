import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sirka_app/core/constants/db.dart';
import 'package:sirka_app/features/product/data/models/product.dart';
import 'package:sirka_app/features/product/presentation/bloc/product_cubit.dart';
import 'package:sirka_app/shared/helpers/print_helper.dart';
import 'package:sirka_app/shared/styles/text_styles.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Map<String, dynamic> args;
  ProductCubit? bloc;
  late Box<Product> productBox;

  @override
  void initState() {
    bloc = BlocProvider.of<ProductCubit>(context);
    productBox = Hive.box<Product>(Db.PRODUCTS);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Product Detail"),
        centerTitle: true,
      ),
      body: buildBlocListener(),
    );
  }

  BlocListener<ProductCubit, ProductState> buildBlocListener() {
    return BlocListener(
      listener: (context, state) {
        if (state is ProductDetailLoaded) {
          printDebug("LOADED");
        } else if (state is WishlistAdded) {
          printDebug("ADDED");
          bloc!.productDetail.value.isWishlist = true;
        } else if (state is WishlistRemoved) {
          bloc!.productDetail.value.isWishlist = false;
          printDebug("REMOVED");
        }
      },
      child: ValueListenableBuilder(
          valueListenable: productBox.listenable(),
          builder: (context, Box<Product> box, child) {
            Product product = box.values.singleWhere((el) => el.id == bloc!.productDetail.value.id);
            return Obx(() {
              String hero = 'hero-${bloc!.productDetail.value.id}';
              return ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(10),
                children: [
                  AspectRatio(
                    aspectRatio: 1.5,
                    child: Hero(
                      tag: hero,
                      child: CachedNetworkImage(
                        imageUrl: product.image!,
                        fit: BoxFit.cover,
                        cacheKey: hero,
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
                  const SizedBox(height: 10),
                  Text(product.name!, style: AppTextStyle.text18sbBlack),
                  const SizedBox(height: 6),
                  Text(
                    product.description!,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text("\$ ${product.price!}", style: AppTextStyle.text14sbBlack),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await bloc!.updateProductWishlist(product: product);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(product.isWishlist! ? Colors.red : Colors.blue),
                    ),
                    child: Text(product.isWishlist! ? 'Remove from wishlist' : 'Add to wishlist'),
                  ),
                ],
              );
            });
          }),
    );
  }
}
