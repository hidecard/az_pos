import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../controllers/cart_controller.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find();
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: product.imageUrl.isNotEmpty
                ? Image.file(
                    File(product.imageUrl),
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.image, size: 50),
                  )
                : Icon(Icons.image, size: 50),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              product.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('\$${product.price.toStringAsFixed(2)}'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Stock: ${product.stock}',
              style: TextStyle(color: product.stock > 0 ? Colors.green : Colors.red),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: product.stock > 0
                  ? () {
                      if (cartController.addToCart(CartItem(product: product))) {
                        Get.snackbar('Success', '${product.name} added to cart');
                      } else {
                        Get.snackbar('Error', 'Not enough stock');
                      }
                    }
                  : null,
              child: Text('Add to Cart'),
            ),
          ),
        ],
      ),
    );
  }
}