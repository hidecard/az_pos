import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:az_pos/controllers/product_controller.dart';
import 'package:az_pos/models/product.dart';

class ProductManagementScreen extends StatelessWidget {
  final ProductController productController = Get.find<ProductController>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String? _imagePath;

  // Show edit dialog
  void _showEditDialog(Product product) {
    final editFormKey = GlobalKey<FormState>();
    final editNameController = TextEditingController(text: product.name);
    final editPriceController = TextEditingController(text: product.price.toStringAsFixed(2));
    final editStockController = TextEditingController(text: product.stock.toString());
    String? editedImagePath = product.imageUrl;
    Widget? imagePreview = product.imageUrl.isNotEmpty
        ? Image.file(File(product.imageUrl), height: 100, fit: BoxFit.cover)
        : null;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Edit Product',
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
                        labelText: 'Product Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      style: GoogleFonts.roboto(),
                      validator: (value) => value!.isEmpty ? 'Enter product name' : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: editPriceController,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.roboto(),
                      validator: (value) => value!.isEmpty ? 'Enter price' : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: editStockController,
                      decoration: InputDecoration(
                        labelText: 'Stock Quantity',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.roboto(),
                      validator: (value) => value!.isEmpty ? 'Enter stock quantity' : null,
                    ),
                    SizedBox(height: 16),
                    if (imagePreview != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: imagePreview,
                      ),
                    ElevatedButton(
                      onPressed: () async {
                        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          editedImagePath = pickedFile.path;
                          setState(() {
                            imagePreview = Image.file(File(editedImagePath!), height: 100, fit: BoxFit.cover);
                          });
                          Get.snackbar(
                            'Success',
                            'New image selected',
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      },
                      child: Text(
                        'Select New Image',
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
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (editFormKey.currentState!.validate()) {
                    await productController.updateProduct(Product(
                      id: product.id,
                      name: editNameController.text,
                      price: double.parse(editPriceController.text),
                      stock: int.parse(editStockController.text),
                      imageUrl: editedImagePath ?? '',
                    ));

                    // Refresh UI
                    productController.products.refresh();

                    // Close dialog
                    if (Get.isDialogOpen ?? false) Get.back();

                    Get.snackbar(
                      'Success',
                      'Product updated',
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
          'Manage Products',
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
                          labelText: 'Product Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        style: GoogleFonts.roboto(),
                        validator: (value) => value!.isEmpty ? 'Enter product name' : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.roboto(),
                        validator: (value) => value!.isEmpty ? 'Enter price' : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _stockController,
                        decoration: InputDecoration(
                          labelText: 'Stock Quantity',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.roboto(),
                        validator: (value) => value!.isEmpty ? 'Enter stock quantity' : null,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            _imagePath = pickedFile.path;
                            Get.snackbar(
                              'Success',
                              'Image selected',
                              snackPosition: SnackPosition.TOP,
                            );
                          }
                        },
                        child: Text(
                          'Select Image',
                          style: GoogleFonts.roboto(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            productController.addProduct(Product(
                              id: DateTime.now().millisecondsSinceEpoch,
                              name: _nameController.text,
                              price: double.parse(_priceController.text),
                              stock: int.parse(_stockController.text),
                              imageUrl: _imagePath ?? '',
                            ));
                            _nameController.clear();
                            _priceController.clear();
                            _stockController.clear();
                            _imagePath = null;
                            Get.snackbar(
                              'Success',
                              'Product added',
                              snackPosition: SnackPosition.TOP,
                            );
                          }
                        },
                        child: Text(
                          'Add Product',
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
                    itemCount: productController.products.length,
                    itemBuilder: (context, index) {
                      final product = productController.products[index];
                      return Card(
                        child: ListTile(
                          leading: product.imageUrl.isNotEmpty
                              ? Image.file(File(product.imageUrl), width: 50, height: 50)
                              : Icon(Icons.image),
                          title: Text(product.name, style: GoogleFonts.roboto()),
                          subtitle: Text(
                            'Price: ${product.price.toStringAsFixed(2)} MMK, Stock: ${product.stock}',
                            style: GoogleFonts.roboto(),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _showEditDialog(product),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  productController.deleteProduct(product.id);
                                  Get.snackbar(
                                    'Success',
                                    'Product deleted',
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
