import 'package:get/get.dart';
import '../models/employee.dart';
import '../services/database_service.dart';

class EmployeeController extends GetxController {
  final DatabaseService _dbService = DatabaseService();
  var employees = <Employee>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    employees.value = await _dbService.getEmployees();
  }

  Future<void> addEmployee(Employee employee) async {
    await _dbService.addEmployee(employee);
    await loadEmployees();
  }

  Future<void> updateEmployee(Employee employee) async {
    await _dbService.updateEmployee(employee);
    await loadEmployees();
  }

  Future<void> deleteEmployee(int id) async {
    await _dbService.deleteEmployee(id);
    await loadEmployees();
  }
}
