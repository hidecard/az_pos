class Customer {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final int loyaltyPoints;
  final double creditBalance;
  final DateTime? dateOfBirth;
  final String notes;

  Customer({
    required this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.loyaltyPoints = 0,
    this.creditBalance = 0.0,
    this.dateOfBirth,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'loyaltyPoints': loyaltyPoints,
      'creditBalance': creditBalance,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'notes': notes,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      loyaltyPoints: map['loyaltyPoints'] ?? 0,
      creditBalance: map['creditBalance']?.toDouble() ?? 0.0,
      dateOfBirth: map['dateOfBirth'] != null ? DateTime.parse(map['dateOfBirth']) : null,
      notes: map['notes'] ?? '',
    );
  }
}
