import 'package:get/get.dart';
import '../models/category.dart';
import '../services/database_service.dart';

class CategoryController extends GetxController {
  final DatabaseService _dbService = DatabaseService();
  var categories = <Category>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    categories.value = await _dbService.getCategories();
  }

  Future<void> addCategory(Category category) async {
    await _dbService.addCategory(category);
    await loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await _dbService.updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _dbService.deleteCategory(id);
    await loadCategories();
  }
}
