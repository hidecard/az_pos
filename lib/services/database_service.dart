import 'dart:async';
import 'package:flutter/foundation.dart';
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
      version: 6, // Incremented version
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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
        items TEXT,
        total REAL,
        date TEXT
      )
    ''');

    // Seed sample data
    await db.insert(tableProducts, {'id': 1, 'name': 'Coffee', 'price': 4.99, 'imageUrl': '', 'stock': 100});
    await db.insert(tableProducts, {'id': 2, 'name': 'Sandwich', 'price': 8.99, 'imageUrl': '', 'stock': 50});
    await db.insert(tableCustomers, {'id': 1, 'name': 'John Doe', 'phone': '1234567890', 'email': 'john@example.com'});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 6) {
      await db.execute('DROP TABLE IF EXISTS $tableOrders');
      await db.execute('''
        CREATE TABLE $tableOrders(
          id INTEGER PRIMARY KEY,
          customerId INTEGER,
          items TEXT,
          total REAL,
          date TEXT
        )
      ''');
    }
  }

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

  Future<List<Order>> getOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableOrders);
    return await compute(_parseOrders, maps);
  }

  static List<Order> _parseOrders(List<Map<String, dynamic>> maps) {
    return maps.map((map) {
      final itemsJson = map['items']?.toString() ?? '[]';
      final List<dynamic> itemsList = jsonDecode(itemsJson);
      final items = itemsList.map((item) => CartItem(
            product: Product(
              id: item['product']['id'],
              name: item['product']['name'],
              price: item['product']['price'].toDouble(),
              stock: item['product']['stock'],
              imageUrl: item['product']['imageUrl'] ?? '',
            ),
            quantity: item['quantity'],
          )).toList();
      return Order(
        id: map['id'],
        customer: Customer(
          id: map['customerId'],
          name: 'Unknown',
          phone: '',
          email: '',
        ),
        items: items,
        total: map['total'].toDouble(),
        date: DateTime.parse(map['date']),
      );
    }).toList();
  }

  Future<Customer> _getCustomerById(int id) async {
    final db = await database;
    final maps = await db.query(tableCustomers, where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) {
      return Customer(id: id, name: 'Unknown', phone: '', email: '');
    }
    return Customer.fromMap(maps.first);
  }

  Future<void> saveOrder(Order order) async {
    try {
      final db = await database;
      final itemsJson = jsonEncode(order.items.map((item) => {
            'product': item.product.toMap(),
            'quantity': item.quantity,
          }).toList());
      await db.insert(
        tableOrders,
        {
          'id': order.id,
          'customerId': order.customer.id,
          'items': itemsJson,
          'total': order.total,
          'date': order.date.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error saving order: $e');
      rethrow;
    }
  }

  Future<void> debugSchema() async {
    final db = await database;
    final result = await db.rawQuery('PRAGMA table_info($tableOrders)');
    print('Orders table schema: $result');
  }
}