import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_controller.dart';
import '../models/customer.dart';

class CustomerManagementScreen extends StatelessWidget {
  final CustomerController customerController = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Customers')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Customer Name'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      customerController.addCustomer(Customer(
                        id: DateTime.now().millisecondsSinceEpoch,
                        name: nameController.text,
                        phone: phoneController.text,
                        email: emailController.text,
                      ));
                      nameController.clear();
                      phoneController.clear();
                      emailController.clear();
                      Get.snackbar('Success', 'Customer added');
                    } else {
                      Get.snackbar('Error', 'Name is required');
                    }
                  },
                  child: Text('Add Customer'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: customerController.customers.length,
                  itemBuilder: (context, index) {
                    final customer = customerController.customers[index];
                    return ListTile(
                      title: Text(customer.name),
                      subtitle: Text('Phone: ${customer.phone} | Email: ${customer.email}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _showEditCustomerDialog(context, customer),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              customerController.deleteCustomer(customer.id);
                              Get.snackbar('Success', 'Customer deleted');
                            },
                          ),
                        ],
                      ),
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }

  void _showEditCustomerDialog(BuildContext context, Customer customer) {
    nameController.text = customer.name;
    phoneController.text = customer.phone;
    emailController.text = customer.email;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Customer Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                customerController.updateCustomer(Customer(
                  id: customer.id,
                  name: nameController.text,
                  phone: phoneController.text,
                  email: emailController.text,
                ));
                Get.back();
                Get.snackbar('Success', 'Customer updated');
              } else {
                Get.snackbar('Error', 'Name is required');
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}