import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/customer_controller.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  final ProductController productController = Get.find();
  final CartController cartController = Get.find();
  final CustomerController customerController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('POS System')),
      body: Obx(() => GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: productController.products.length,
            cacheExtent: 9999,
            itemBuilder: (context, index) {
              return ProductCard(product: productController.products[index]);
            },
          )),
    );
  }
}