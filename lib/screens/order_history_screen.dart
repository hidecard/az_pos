import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:az_pos/controllers/order_controller.dart';
import 'package:az_pos/models/order.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderHistoryScreen extends StatelessWidget {
  final OrderController orderController = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order History',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (orderController.orders.isEmpty) {
          return Center(
            child: Text(
              'No order history',
              style: GoogleFonts.roboto(fontSize: 18),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: orderController.orders.length,
          itemBuilder: (context, index) {
            final order = orderController.orders[index];
            return Card(
              child: ListTile(
                title: Text(
                  'Order ID: ${order.id}',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer: ${order.customer.name ?? 'Unknown'}',
                      style: GoogleFonts.roboto(),
                    ),
                    Text(
                      'Total Amount: ${order.total} MMK',
                      style: GoogleFonts.roboto(),
                    ),
                    Text(
                      'Date: ${order.date.toString().substring(0, 10)}',
                      style: GoogleFonts.roboto(),
                    ),
                  ],
                ),
                onTap: () {
                  Get.to(() => OrderDetailScreen(order: order));
                },
              ),
            );
          },
        );
      }),
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  OrderDetailScreen({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ID: ${order.id}',
                  style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Customer: ${order.customer.name ?? 'Unknown'}',
                  style: GoogleFonts.roboto(fontSize: 16),
                ),
                Text(
                  'Total Amount: ${order.total} MMK',
                  style: GoogleFonts.roboto(fontSize: 16),
                ),
                Text(
                  'Date: ${order.date.toString().substring(0, 10)}',
                  style: GoogleFonts.roboto(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  'Items:',
                  style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: order.items.length,
                    itemBuilder: (context, index) {
                      final item = order.items[index];
                      return ListTile(
                        title: Text(item.product.name, style: GoogleFonts.roboto()),
                        subtitle: Text(
                          'Quantity: ${item.quantity}',
                          style: GoogleFonts.roboto(),
                        ),
                        trailing: Text(
                          '${item.quantity * item.product.price} MMK',
                          style: GoogleFonts.roboto(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}