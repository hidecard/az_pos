import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../controllers/customer_controller.dart';
import '../models/customer.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final CartController cartController = Get.find();
  final CustomerController customerController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: Obx(() => Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: DropdownButton<Customer>(
              hint: Text('Select Customer'),
              value: cartController.selectedCustomer.value,
              items: customerController.customers
                  .map((customer) => DropdownMenuItem<Customer>(
                        value: customer,
                        child: Text(customer.name),
                      ))
                  .toList(),
              onChanged: (Customer? customer) {
                if (customer != null) {
                  cartController.setCustomer(customer);
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cartController.cartItems.length,
              itemBuilder: (context, index) {
                final item = cartController.cartItems[index];
                return ListTile(
                  title: Text(item.product.name),
                  subtitle: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          if (item.quantity > 1) {
                            item.quantity--;
                            cartController.cartItems.refresh();
                          } else {
                            cartController.removeFromCart(index);
                          }
                        },
                      ),
                      Text('Qty: ${item.quantity}'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          if (item.product.stock >= item.quantity + 1) {
                            item.quantity++;
                            cartController.cartItems.refresh();
                          } else {
                            Get.snackbar('Error', 'Not enough stock');
                          }
                        },
                      ),
                    ],
                  ),
                  trailing: Text('\$${item.total}'),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Total: \$${cartController.totalAmount}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () => Get.to(() => CheckoutScreen()),
                  child: Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}