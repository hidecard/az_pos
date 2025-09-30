import 'package:get/get.dart';
import '../models/customer.dart';
import '../services/database_service.dart';

class CustomerController extends GetxController {
  final DatabaseService _dbService = DatabaseService();
  var customers = <Customer>[].obs;

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

  Future<void> addLoyaltyPoints(int customerId, int points) async {
    final customer = customers.firstWhere((c) => c.id == customerId);
    final updatedCustomer = Customer(
      id: customer.id,
      name: customer.name,
      phone: customer.phone,
      email: customer.email,
      address: customer.address,
      loyaltyPoints: customer.loyaltyPoints + points,
      creditBalance: customer.creditBalance,
      dateOfBirth: customer.dateOfBirth,
      notes: customer.notes,
    );
    await updateCustomer(updatedCustomer);
  }

  Future<void> updateCreditBalance(int customerId, double amount) async {
    final customer = customers.firstWhere((c) => c.id == customerId);
    final updatedCustomer = Customer(
      id: customer.id,
      name: customer.name,
      phone: customer.phone,
      email: customer.email,
      address: customer.address,
      loyaltyPoints: customer.loyaltyPoints,
      creditBalance: customer.creditBalance + amount,
      dateOfBirth: customer.dateOfBirth,
      notes: customer.notes,
    );
    await updateCustomer(updatedCustomer);
  }
}
