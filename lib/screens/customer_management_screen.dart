import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:az_pos/controllers/customer_controller.dart';
import 'package:az_pos/models/customer.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerManagementScreen extends StatelessWidget {
  CustomerManagementScreen({super.key});

  final CustomerController customerController = Get.find<CustomerController>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Show edit dialog
  void _showEditDialog(Customer customer) {
    final editFormKey = GlobalKey<FormState>();
    final editNameController = TextEditingController(text: customer.name);
    final editPhoneController = TextEditingController(text: customer.phone);
    final editEmailController = TextEditingController(text: customer.email);

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Edit Customer',
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: editFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: editNameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      style: GoogleFonts.roboto(),
                      validator: (value) => value!.isEmpty ? 'Enter name' : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: editPhoneController,
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
                      controller: editEmailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.roboto(),
                      validator: (value) => value!.isEmpty ? 'Enter email' : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (editFormKey.currentState!.validate()) {
                    customerController.updateCustomer(Customer(
                      id: customer.id,
                      name: editNameController.text,
                      phone: editPhoneController.text,
                      email: editEmailController.text,
                    ));

                    // Refresh UI
                    customerController.customers.refresh();

                    // Close dialog
                    if (Get.isDialogOpen ?? false) Get.back();

                    Get.snackbar(
                      'Success',
                      'Customer updated',
                      snackPosition: SnackPosition.TOP,
                    );
                  }
                },
                child: Text(
                  'Update',
                  style: GoogleFonts.roboto(fontSize: 16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

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
            // Add Customer Form
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
                              snackPosition: SnackPosition.TOP,
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

            // Customer List
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _showEditDialog(customer),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  customerController.deleteCustomer(customer.id);
                                  Get.snackbar(
                                    'Success',
                                    'Customer deleted',
                                    snackPosition: SnackPosition.TOP,
                                  );
                                },
                              ),
                            ],
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
