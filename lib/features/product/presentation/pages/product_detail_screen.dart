import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirka_app/features/product/data/models/product.dart';
import 'package:sirka_app/shared/styles/text_styles.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Map<String, dynamic> args;
  late Product product;
  late String hero;
  @override
  void initState() {
    super.initState();
    args = Get.arguments as Map<String, dynamic>;
    product = args['product'];
    hero = args['hero'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Product Detail"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: ListView(
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
                  cacheKey: "hero-${product.id}",
                ),
              ),
            ),
            const SizedBox(height: 10),
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
    );
  }
}
