import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';

class ProductManagementScreen extends StatelessWidget {
  final ProductController productController = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final RxString imagePath = ''.obs;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.png';
      final savedImage = await File(pickedFile.path).copy('${directory.path}/$fileName');
      imagePath.value = savedImage.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Products')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: stockController,
                  decoration: InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                ),
                Obx(() => imagePath.value.isNotEmpty
                    ? Image.file(File(imagePath.value), height: 100)
                    : Text('No image selected')),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        priceController.text.isNotEmpty &&
                        stockController.text.isNotEmpty) {
                      productController.addProduct(Product(
                        id: DateTime.now().millisecondsSinceEpoch,
                        name: nameController.text,
                        price: double.parse(priceController.text),
                        stock: int.parse(stockController.text),
                        imageUrl: imagePath.value,
                      ));
                      nameController.clear();
                      priceController.clear();
                      stockController.clear();
                      imagePath.value = '';
                      Get.snackbar('Success', 'Product added');
                    } else {
                      Get.snackbar('Error', 'Fill all fields');
                    }
                  },
                  child: Text('Add Product'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: productController.products.length,
                  itemBuilder: (context, index) {
                    final product = productController.products[index];
                    return ListTile(
                      leading: product.imageUrl.isNotEmpty
                          ? Image.file(File(product.imageUrl), width: 50, height: 50)
                          : Icon(Icons.image),
                      title: Text(product.name),
                      subtitle: Text('Price: \$${product.price} | Stock: ${product.stock}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _showEditProductDialog(context, product),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              productController.deleteProduct(product.id);
                              Get.snackbar('Success', 'Product deleted');
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

  void _showEditProductDialog(BuildContext context, Product product) {
    nameController.text = product.name;
    priceController.text = product.price.toString();
    stockController.text = product.stock.toString();
    imagePath.value = product.imageUrl;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: stockController,
              decoration: InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
            ),
            Obx(() => imagePath.value.isNotEmpty
                ? Image.file(File(imagePath.value), height: 100)
                : Text('No image selected')),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
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
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty &&
                  stockController.text.isNotEmpty) {
                productController.updateProduct(Product(
                  id: product.id,
                  name: nameController.text,
                  price: double.parse(priceController.text),
                  stock: int.parse(stockController.text),
                  imageUrl: imagePath.value,
                ));
                Get.back();
                Get.snackbar('Success', 'Product updated');
              } else {
                Get.snackbar('Error', 'Fill all fields');
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}