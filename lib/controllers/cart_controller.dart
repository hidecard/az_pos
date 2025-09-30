import 'package:get/get.dart';
import '../models/cart_item.dart';
import '../models/customer.dart';
import '../models/order.dart';
import '../models/payment_method.dart';
import '../services/database_service.dart';

class CartController extends GetxController {
  final DatabaseService _dbService = DatabaseService();
  var cartItems = <CartItem>[].obs;
  var selectedCustomer = Rx<Customer?>(null);
  var selectedPaymentMethod = Rx<PaymentMethod?>(null);
  var totalAmount = 0.0.obs;
  var isLoading = false.obs; // Added for loading state

  bool addToCart(CartItem item) {
    final existingItem = cartItems.firstWhereOrNull((i) => i.product.id == item.product.id);
    if (existingItem != null) {
      if (existingItem.product.stock >= existingItem.quantity + 1) {
        existingItem.quantity++;
        cartItems.refresh();
        calculateTotal();
        return true;
      } else {
        Get.snackbar('Error', 'Not enough stock');
        return false;
      }
    } else {
      if (item.product.stock >= item.quantity) {
        cartItems.add(item);
        calculateTotal();
        return true;
      } else {
        Get.snackbar('Error', 'Not enough stock');
        return false;
      }
    }
  }

  void removeFromCart(int index) {
    cartItems.removeAt(index);
    calculateTotal();
  }

  void setCustomer(Customer customer) {
    selectedCustomer.value = customer;
  }

  void calculateTotal() {
    totalAmount.value = cartItems.fold(0.0, (sum, item) => sum + item.total);
  }

  Future<void> checkout() async {
    if (cartItems.isEmpty || selectedCustomer.value == null || selectedPaymentMethod.value == null) {
      throw Exception('Cart is empty, no customer selected, or no payment method selected');
    }
    isLoading.value = true; // Set loading
    try {
      for (var item in cartItems) {
        await _dbService.updateStock(item.product.id, item.product.stock - item.quantity);
      }
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch,
        customer: selectedCustomer.value!,
        items: cartItems.toList(),
        total: totalAmount.value,
        date: DateTime.now(),
        paymentMethod: selectedPaymentMethod.value!,
      );
      await _dbService.saveOrder(order);
      cartItems.clear();
      selectedCustomer.value = null;
      selectedPaymentMethod.value = null;
      totalAmount.value = 0.0;
    } finally {
      isLoading.value = false; // Reset loading
    }
  }
}