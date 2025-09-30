import 'cart_item.dart';
import 'customer.dart';
import 'payment_method.dart';

class Order {
  final int id;
  final Customer customer;
  final List<CartItem> items;
  final double total;
  final DateTime date;
  final PaymentMethod paymentMethod;

  Order({
    required this.id,
    required this.customer,
    required this.items,
    required this.total,
    required this.date,
    required this.paymentMethod,
  });
}
