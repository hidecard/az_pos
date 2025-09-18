import 'package:get/get.dart';
import '../models/cart_item.dart';
import '../models/customer.dart';
import '../models/order.dart';
import '../services/database_service.dart';

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;
  var selectedCustomer = Rxn<Customer>();
  final DatabaseService _dbService = DatabaseService();

  bool addToCart(CartItem item) {
    if (item.product.stock < item.quantity) {
      Get.snackbar('Error', 'Not enough stock for ${item.product.name}');
      return false;
    }
    var existingIndex = cartItems.indexWhere((c) => c.product.id == item.product.id);
    if (existingIndex >= 0) {
      if (cartItems[existingIndex].product.stock >= cartItems[existingIndex].quantity + item.quantity) {
        cartItems[existingIndex].quantity += item.quantity;
      } else {
        Get.snackbar('Error', 'Not enough stock for ${item.product.name}');
        return false;
      }
    } else {
      cartItems.add(item);
    }
    cartItems.refresh();
    return true;
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems.removeAt(index);
    }
  }

  void setCustomer(Customer customer) {
    selectedCustomer.value = customer;
  }

  double get totalAmount {
    return cartItems.fold(0.0, (sum, item) => sum + item.total);
  }

  Future<void> checkout() async {
    if (selectedCustomer.value == null) {
      Get.snackbar('Error', 'Please select a customer');
      return;
    }
    for (var item in cartItems) {
      await _dbService.updateStock(item.product.id, item.product.stock - item.quantity);
    }
    await _dbService.saveOrder(Order(
      id: DateTime.now().millisecondsSinceEpoch,
      customer: selectedCustomer.value!,
      items: cartItems.toList(),
      total: totalAmount,
      date: DateTime.now(),
    ));
    print('Receipt printed for order total: \$${totalAmount} for ${selectedCustomer.value!.name}');
    cartItems.clear();
    selectedCustomer.value = null;
    Get.snackbar('Success', 'Order completed and stock updated!');
  }
}