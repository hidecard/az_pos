import 'package:get/get.dart';
import '../models/order.dart';
import '../services/database_service.dart';

class OrderController extends GetxController {
  final DatabaseService _dbService = DatabaseService();
  var orders = <Order>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    orders.value = await _dbService.getOrders();
  }
}