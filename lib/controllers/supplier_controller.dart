import 'package:get/get.dart';
import '../models/supplier.dart';
import '../services/database_service.dart';

class SupplierController extends GetxController {
  final DatabaseService _dbService = DatabaseService();
  var suppliers = <Supplier>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    suppliers.value = await _dbService.getSuppliers();
  }

  Future<void> addSupplier(Supplier supplier) async {
    await _dbService.addSupplier(supplier);
    await loadSuppliers();
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await _dbService.updateSupplier(supplier);
    await loadSuppliers();
  }

  Future<void> deleteSupplier(int id) async {
    await _dbService.deleteSupplier(id);
    await loadSuppliers();
  }
}
