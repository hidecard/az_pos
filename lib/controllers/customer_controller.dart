import 'package:get/get.dart';
import '../models/customer.dart';
import '../services/database_service.dart';

class CustomerController extends GetxController {
  var customers = <Customer>[].obs;
  final DatabaseService _dbService = DatabaseService();

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    customers.value = await _dbService.getCustomers();
  }

  Future<void> addCustomer(Customer customer) async {
    await _dbService.addCustomer(customer);
    await loadCustomers();
  }

  Future<void> updateCustomer(Customer customer) async {
    await _dbService.updateCustomer(customer);
    await loadCustomers();
  }

  Future<void> deleteCustomer(int id) async {
    await _dbService.deleteCustomer(id);
    await loadCustomers();
  }
}