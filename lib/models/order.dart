import 'cart_item.dart';
import 'customer.dart';
import 'payment_method.dart';

enum OrderStatus {
  pending,
  paid,
  credit,
  cancelled,
}

class Order {
  final int id;
  final Customer customer;
  final List<CartItem> items;
  final double total;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final OrderStatus status;
  final int? employeeId;
  final double discount;
  final double tax;

  Order({
    required this.id,
    required this.customer,
    required this.items,
    required this.total,
    required this.date,
    required this.paymentMethod,
    this.status = OrderStatus.pending,
    this.employeeId,
    this.discount = 0.0,
    this.tax = 0.0,
  });
}
