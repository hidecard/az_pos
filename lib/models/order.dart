import 'cart_item.dart';
import 'customer.dart';

class Order {
  final int id;
  final Customer customer;
  final List<CartItem> items;
  final double total;
  final DateTime date;

  Order({
    required this.id,
    required this.customer,
    required this.items,
    required this.total,
    required this.date,
  });
}