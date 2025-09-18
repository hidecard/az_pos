import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/customer_controller.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  final ProductController productController = Get.put(ProductController());
  final CartController cartController = Get.put(CartController());
  final CustomerController customerController = Get.put(CustomerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: Obx(() => GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: productController.products.length,
        itemBuilder: (context, index) {
          return ProductCard(product: productController.products[index]);
        },
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/cart'),
        child: Icon(Icons.shopping_cart),
      ),
    );
  }
}