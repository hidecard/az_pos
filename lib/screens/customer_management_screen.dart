import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:az_pos/controllers/customer_controller.dart';
import 'package:az_pos/models/customer.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerManagementScreen extends StatelessWidget {
  final CustomerController customerController = Get.find<CustomerController>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Customers',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        style: GoogleFonts.roboto(),
                        validator: (value) => value!.isEmpty ? 'Enter name' : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.roboto(),
                        validator: (value) => value!.isEmpty ? 'Enter phone number' : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.roboto(),
                        validator: (value) => value!.isEmpty ? 'Enter email' : null,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            customerController.addCustomer(Customer(
                              id: DateTime.now().millisecondsSinceEpoch,
                              name: _nameController.text,
                              phone: _phoneController.text,
                              email: _emailController.text,
                            ));
                            _nameController.clear();
                            _phoneController.clear();
                            _emailController.clear();
                            Get.snackbar(
                              'Success',
                              'Customer added',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                        child: Text(
                          'Add Customer',
                          style: GoogleFonts.roboto(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: customerController.customers.length,
                    itemBuilder: (context, index) {
                      final customer = customerController.customers[index];
                      return Card(
                        child: ListTile(
                          title: Text(customer.name, style: GoogleFonts.roboto()),
                          subtitle: Text(
                            'Phone: ${customer.phone}, Email: ${customer.email}',
                            style: GoogleFonts.roboto(),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              customerController.deleteCustomer(customer.id);
                              Get.snackbar(
                                'Success',
                                'Customer deleted',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }
}