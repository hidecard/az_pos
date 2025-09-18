import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/product_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/customer_controller.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.put(ProductController());
    Get.put(CartController());
    Get.put(CustomerController());
    return GetMaterialApp(
      title: 'POS System',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
      getPages: [
        GetPage(name: '/cart', page: () => CartScreen()),
      ],
    );
  }
}