import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';

class OrderHistoryScreen extends StatelessWidget {
  final OrderController orderController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order History')),
      body: Obx(() => ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: orderController.orders.length,
            itemBuilder: (context, index) {
              final order = orderController.orders[index];
              return ExpansionTile(
                title: Text('Order #${order.id} - ${order.customer.name}'),
                subtitle: Text('Total: \$${order.total.toStringAsFixed(2)} | Date: ${order.date.toString()}'),
                children: order.items
                    .asMap()
                    .entries
                    .map((entry) => ListTile(
                          title: Text(entry.value.product.name),
                          subtitle: Text('Quantity: ${entry.value.quantity} | \$${entry.value.total.toStringAsFixed(2)}'),
                        ))
                    .toList(),
              );
            },
          )),
    );
  }
}