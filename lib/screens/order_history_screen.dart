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
            itemCount: orderController.orders.length,
            itemBuilder: (context, index) {
              final order = orderController.orders[index];
              return ExpansionTile(
                title: Text('Order #${order.id} - ${order.customer.name}'),
                subtitle: Text('Total: \$${order.total} | Date: ${order.date.toString()}'),
                children: order.items
                    .asMap()
                    .entries
                    .map((entry) => ListTile(
                          title: Text(entry.value.product.name),
                          subtitle: Text('Qty: ${entry.value.quantity} | \$${entry.value.total}'),
                        ))
                    .toList(),
              );
            },
          )),
    );
  }
}