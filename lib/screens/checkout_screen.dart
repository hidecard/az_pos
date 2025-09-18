import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import 'home_screen.dart';

class CheckoutScreen extends StatelessWidget {
  final CartController cartController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Customer: ${cartController.selectedCustomer.value?.name ?? "None"}'),
            Text('Total: \$${cartController.finalTotal}'),
            ElevatedButton(
              onPressed: () async {
                await cartController.checkout();
                Get.offAll(() => HomeScreen()); // Clear stack and go to home
              },
              child: Text('Pay & Complete Order'),
            ),
          ],
        ),
      ),
    );
  }
}