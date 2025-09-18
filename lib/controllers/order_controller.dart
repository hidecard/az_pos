import 'package:get/get.dart';
import '../models/order.dart';
import '../services/database_service.dart';

class OrderController extends GetxController {
  var orders = <Order>[].obs;
  final DatabaseService _dbService = DatabaseService();

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    orders.value = await _dbService.getOrders();
  }
}