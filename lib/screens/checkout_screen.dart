import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../controllers/order_controller.dart'; // Add this import
import '../models/customer.dart'; // Add this import
import '../services/database_service.dart'; // Add this import for DatabaseService
import '../main.dart'; // Import main.dart to access MainScreen

class CheckoutScreen extends StatelessWidget {
  final CartController cartController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Header
              Text(
                'Order Summary',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 16),
              // Customer and Total Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        cartController.selectedCustomer.value?.name ?? 'Guest',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Divider(height: 24),
                      Text(
                        'Total Amount',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${cartController.totalAmount.toStringAsFixed(2)} MMK',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              // Cart Items Review
              Text(
                'Items in Cart',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              cartController.cartItems.isEmpty
                  ? Center(
                      child: Text(
                        'No items in cart',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: cartController.cartItems.length,
                      separatorBuilder: (context, index) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = cartController.cartItems[index];
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(12),
                            title: Text(
                              item.product.name,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              'Quantity: ${item.quantity}',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            trailing: Text(
                              '${item.total.toStringAsFixed(2)} MMK',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              SizedBox(height: 24),
              // Checkout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                  ),
                  onPressed: cartController.cartItems.isEmpty
                      ? null
                      : () async {
                          try {
                            if (cartController.selectedCustomer.value == null) {
                              cartController.selectedCustomer.value = Customer(
                                id: 0,
                                name: 'Guest',
                                phone: '',
                                email: '',
                              );
                            }
                            // Save the guest customer to the database to avoid unknown in history
                            final dbService = DatabaseService();
                            await dbService.addCustomer(cartController.selectedCustomer.value!);
                            await cartController.checkout();
                            final orderController = Get.find<OrderController>();
                            await orderController.loadOrders();
                            Get.offAll(() => MainScreen());
                            Get.snackbar(
                              'Success',
                              'Order completed',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          } catch (e) {
                            Get.dialog(
                              AlertDialog(
                                title: Text('Error'),
                                content: Text('Failed to complete order: $e'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                  child: cartController.isLoading.value == true
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Pay & Complete Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}