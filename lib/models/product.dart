class Product {
  final int id;
  final String name;
  final double price;
  final double cost;
  final String sku;
  final String barcode;
  final int? categoryId;
  final int? supplierId;
  final int minStock;
  final String description;
  final String imageUrl;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.cost = 0.0,
    this.sku = '',
    this.barcode = '',
    this.categoryId,
    this.supplierId,
    this.minStock = 0,
    this.description = '',
    this.imageUrl = '',
    required this.stock,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'cost': cost,
      'sku': sku,
      'barcode': barcode,
      'categoryId': categoryId,
      'supplierId': supplierId,
      'minStock': minStock,
      'description': description,
      'imageUrl': imageUrl,
      'stock': stock,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'].toDouble(),
      cost: map['cost']?.toDouble() ?? 0.0,
      sku: map['sku'] ?? '',
      barcode: map['barcode'] ?? '',
      categoryId: map['categoryId'],
      supplierId: map['supplierId'],
      minStock: map['minStock'] ?? 0,
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      stock: map['stock'],
    );
  }

  bool get isLowStock => stock <= minStock;
}
