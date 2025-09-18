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
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Customer: ${cartController.selectedCustomer.value?.name ?? "None"}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              Text(
                'Total: \$${cartController.totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: TextStyle(fontSize: 16),
                ),
                onPressed: () async {
                  try {
                    await cartController.checkout();
                    Get.offAll(() => HomeScreen());
                    Get.snackbar('Success', 'Order completed');
                  } catch (e) {
                    Get.snackbar('Error', 'Failed to complete order: $e');
                  }
                },
                child: Text('Pay & Complete Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}