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
      child: Column(
        children: [
          Expanded(
            child: product.imageUrl.isNotEmpty
                ? Image.asset(
                    product.imageUrl,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.image, size: 50),
                  )
                : Icon(Icons.image, size: 50),
          ),
          Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
          Text('\$${product.price}'),
          Text('Stock: ${product.stock}', style: TextStyle(color: product.stock > 0 ? Colors.green : Colors.red)),
          ElevatedButton(
            onPressed: product.stock > 0
                ? () {
                    if (cartController.addToCart(CartItem(product: product))) {
                      Get.snackbar('Added', '${product.name} added to cart');
                    }
                  }
                : null,
            child: Text('Add to Cart'),
          ),
        ],
      ),
    );
  }
}