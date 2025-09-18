import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import './home_screen.dart'; // Import MainScreen instead of HomeScreen

class CheckoutScreen extends StatelessWidget {
  final CartController cartController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ပေးချေမည်')), // Burmese label
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ဖောက်သည်: ${cartController.selectedCustomer.value?.name ?? "မရှိ"}'),
            Text('စုစုပေါင်း: \$${cartController.totalAmount}'),
            ElevatedButton(
              onPressed: () async {
                try {
                  await cartController.checkout();
                  Get.offAll(() => HomeScreen()); // Navigate to MainScreen
                  Get.snackbar('အောင်မြင်ပါသည်', 'အော်ဒါပြီးဆုံးပြီ');
                } catch (e) {
                  Get.snackbar('အမှား', 'အော်ဒါမပြီးဆုံးနိုင်ပါ: $e');
                }
              },
              child: Text('ပေးချေပြီး အော်ဒါပြီးဆုံးမည်'),
            ),
          ],
        ),
      ),
    );
  }
}