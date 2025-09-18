import 'package:get/get.dart';
import '../models/product.dart';
import '../services/database_service.dart';

class ProductController extends GetxController {
  var products = <Product>[].obs;
  final DatabaseService _dbService = DatabaseService();

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    products.value = await _dbService.getProducts();
  }

  Future<void> addProduct(Product product) async {
    await _dbService.addProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(Product product) async {
    await _dbService.updateProduct(product);
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _dbService.deleteProduct(id);
    await loadProducts();
  }
}