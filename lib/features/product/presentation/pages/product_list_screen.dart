import 'package:flutter/material.dart';
import 'package:sirka_app/features/product/presentation/pages/product_detail_screen.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Product List"),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductDetailScreen())),
          child: const Text("Product List Screen"),
        ),
      ),
    );
  }
}
