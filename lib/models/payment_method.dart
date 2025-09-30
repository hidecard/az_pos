enum PaymentMethod {
  cash,
  card,
  digital,
  credit,
}

extension PaymentMethodExtension on PaymentMethod {
  String get name {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.digital:
        return 'Digital';
      case PaymentMethod.credit:
        return 'Credit';
    }
  }

  static PaymentMethod fromString(String value) {
    switch (value.toLowerCase()) {
      case 'cash':
        return PaymentMethod.cash;
      case 'card':
        return PaymentMethod.card;
      case 'digital':
        return PaymentMethod.digital;
      case 'credit':
        return PaymentMethod.credit;
    }
    throw ArgumentError('Invalid payment method: $value');
  }
}
