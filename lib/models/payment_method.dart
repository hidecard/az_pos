enum PaymentMethod {
  cash,
  card,
  digital,
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
      default:
        return PaymentMethod.cash; // default fallback
    }
  }
}
