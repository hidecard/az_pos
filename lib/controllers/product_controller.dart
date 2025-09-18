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
}