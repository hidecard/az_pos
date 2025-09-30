class Supplier {
  final int id;
  final String name;
  final String contact;
  final String address;
  final String phone;
  final String email;

  Supplier({
    required this.id,
    required this.name,
    this.contact = '',
    this.address = '',
    this.phone = '',
    this.email = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'address': address,
      'phone': phone,
      'email': email,
    };
  }

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'],
      name: map['name'],
      contact: map['contact'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
    );
  }
}
