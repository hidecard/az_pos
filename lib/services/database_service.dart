import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import 'dart:convert';

class DatabaseService {
  static Database? _database;
  static const String tableProducts = 'products';
  static const String tableCustomers = 'customers';
  static const String tableOrders = 'orders';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'pos.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableProducts(
        id INTEGER PRIMARY KEY,
        name TEXT,
        price REAL,
        imageUrl TEXT,
        stock INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableCustomers(
        id INTEGER PRIMARY KEY,
        name TEXT,
        phone TEXT,
        email TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableOrders(
        id INTEGER PRIMARY KEY,
        customerId INTEGER,
        items TEXT,  -- Store items as JSON
        total REAL,
        date TEXT
      )
    ''');

    // Seed sample data
    await db.insert(tableProducts, {'id': 1, 'name': 'Coffee', 'price': 4.99, 'imageUrl': '', 'stock': 100});
    await db.insert(tableProducts, {'id': 2, 'name': 'Sandwich', 'price': 8.99, 'imageUrl': '', 'stock': 50});
    await db.insert(tableCustomers, {'id': 1, 'name': 'John Doe', 'phone': '1234567890', 'email': 'john@example.com'});
  }

  // Product CRUD
  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableProducts);
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<void> addProduct(Product product) async {
    final db = await database;
    await db.insert(tableProducts, product.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      tableProducts,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete(tableProducts, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateStock(int productId, int newStock) async {
    final db = await database;
    await db.update(
      tableProducts,
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  // Customer CRUD
  Future<List<Customer>> getCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableCustomers);
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  Future<void> addCustomer(Customer customer) async {
    final db = await database;
    await db.insert(tableCustomers, customer.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateCustomer(Customer customer) async {
    final db = await database;
    await db.update(
      tableCustomers,
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<void> deleteCustomer(int id) async {
    final db = await database;
    await db.delete(tableCustomers, where: 'id = ?', whereArgs: [id]);
  }

  // Order History
  Future<List<Order>> getOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableOrders);
    return Future.wait(maps.map((map) async {
      final customer = await _getCustomerById(map['customerId']);
      final itemsJson = map['items'] as String;
      final List<dynamic> itemsList = jsonDecode(itemsJson);
      final items = itemsList.map((item) => CartItem(
            product: Product(
              id: item['product']['id'],
              name: item['product']['name'],
              price: item['product']['price'].toDouble(),
              stock: item['product']['stock'],
              imageUrl: item['product']['imageUrl'],
            ),
            quantity: item['quantity'],
          )).toList();
      return Order(
        id: map['id'],
        customer: customer,
        items: items,
        total: map['total'].toDouble(),
        date: DateTime.parse(map['date']),
      );
    }).toList());
  }

  Future<Customer> _getCustomerById(int id) async {
    final db = await database;
    final maps = await db.query(tableCustomers, where: 'id = ?', whereArgs: [id]);
    return Customer.fromMap(maps.first);
  }

  Future<void> saveOrder(Order order) async {
    final db = await database;
    final itemsJson = jsonEncode(order.items.map((item) => {
          'product': item.product.toMap(),
          'quantity': item.quantity,
        }).toList());
    await db.insert(tableOrders, {
      'id': order.id,
      'customerId': order.customer.id,
      'items': itemsJson,
      'total': order.total,
      'date': order.date.toIso8601String(),
    });
  }
}