import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../controllers/order_controller.dart';
import '../models/customer.dart';
import '../services/database_service.dart';
import '../main.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

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

                            final dbService = DatabaseService();
                            await dbService.addCustomer(cartController.selectedCustomer.value!);

                            final itemsToPrint = List.from(cartController.cartItems);
                            final totalAmount = cartController.totalAmount;

                            // Generate Invoice PDF
                            final pdf = pw.Document();
                            final now = DateTime.now();
                            final formatter = DateFormat('yyyy-MM-dd HH:mm');

                            pdf.addPage(pw.Page(
                              pageFormat: PdfPageFormat.a4,
                              build: (pw.Context context) {
                                return pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    // Header
                                    pw.Text('My Shop',
                                        style: pw.TextStyle(
                                            fontSize: 28, fontWeight: pw.FontWeight.bold)),
                                    pw.SizedBox(height: 8),
                                    pw.Text('Invoice',
                                        style: pw.TextStyle(
                                            fontSize: 20, fontWeight: pw.FontWeight.bold)),
                                    pw.SizedBox(height: 16),
                                    // Subheader
                                    pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text('Invoice No: ${now.millisecondsSinceEpoch}'),
                                            pw.Text('Date: ${formatter.format(now)}'),
                                          ],
                                        ),
                                        pw.Column(
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text('Customer: ${cartController.selectedCustomer.value?.name ?? 'Guest'}'),
                                            pw.Text('Phone: ${cartController.selectedCustomer.value?.phone ?? '-'}'),
                                          ],
                                        )
                                      ],
                                    ),
                                    pw.SizedBox(height: 16),
                                    // Table
                                    pw.Table.fromTextArray(
                                      headers: ['Product', 'Qty', 'Price', 'Total'],
                                      data: itemsToPrint.map((item) => [
                                        item.product.name,
                                        item.quantity.toString(),
                                        item.product.price.toStringAsFixed(2),
                                        item.total.toStringAsFixed(2)
                                      ]).toList(),
                                      headerStyle: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                                      headerDecoration: pw.BoxDecoration(color: PdfColors.blue),
                                      cellPadding: pw.EdgeInsets.all(6),
                                    ),
                                    pw.Divider(),
                                    pw.SizedBox(height: 8),
                                    pw.Align(
                                      alignment: pw.Alignment.centerRight,
                                      child: pw.Text(
                                        'Total: ${totalAmount.toStringAsFixed(2)} MMK',
                                        style: pw.TextStyle(
                                            fontSize: 18, fontWeight: pw.FontWeight.bold),
                                      ),
                                    ),
                                    pw.SizedBox(height: 16),
                                    // Footer
                                    pw.Center(
                                      child: pw.Text(
                                        'Thank you for your purchase!',
                                        style: pw.TextStyle(
                                            fontSize: 16, fontWeight: pw.FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ));

                            await Printing.layoutPdf(onLayout: (format) => pdf.save());

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
                  child: cartController.isLoading.value
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
