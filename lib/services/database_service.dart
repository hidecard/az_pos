import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/payment_method.dart';
import '../models/category.dart';
import '../models/supplier.dart';
import '../models/employee.dart';
import '../models/stock_transaction.dart';
import 'dart:convert';

class DatabaseService {
  static Database? _database;
  static const String tableProducts = 'products';
  static const String tableCustomers = 'customers';
  static const String tableOrders = 'orders';
  static const String tableCategories = 'categories';
  static const String tableSuppliers = 'suppliers';
  static const String tableEmployees = 'employees';
  static const String tableStockTransactions = 'stock_transactions';
  static const String dbName = 'pos.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), dbName);
    return await openDatabase(
      path,
      version: 8,
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
        cost REAL DEFAULT 0.0,
        sku TEXT,
        barcode TEXT,
        categoryId INTEGER,
        supplierId INTEGER,
        minStock INTEGER DEFAULT 0,
        description TEXT,
        imageUrl TEXT,
        stock INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableCustomers(
        id INTEGER PRIMARY KEY,
        name TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        loyaltyPoints INTEGER DEFAULT 0,
        creditBalance REAL DEFAULT 0.0,
        dateOfBirth TEXT,
        notes TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableOrders(
        id INTEGER PRIMARY KEY,
        customerId INTEGER,
        items TEXT,
        total REAL,
        date TEXT,
        paymentMethod TEXT,
        status INTEGER DEFAULT 0,
        employeeId INTEGER,
        discount REAL DEFAULT 0.0,
        tax REAL DEFAULT 0.0
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableCategories(
        id INTEGER PRIMARY KEY,
        name TEXT,
        description TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableSuppliers(
        id INTEGER PRIMARY KEY,
        name TEXT,
        contact TEXT,
        address TEXT,
        phone TEXT,
        email TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableEmployees(
        id INTEGER PRIMARY KEY,
        name TEXT,
        role TEXT,
        username TEXT,
        password TEXT,
        isActive INTEGER DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableStockTransactions(
        id INTEGER PRIMARY KEY,
        productId INTEGER,
        type INTEGER,
        quantity INTEGER,
        date TEXT,
        reason TEXT,
        employeeId INTEGER
      )
    ''');

    // Seed sample data
    await db.insert(tableProducts, {'id': 1, 'name': 'Coffee', 'price': 4.99, 'cost': 2.0, 'sku': 'COF001', 'barcode': '123456789', 'minStock': 10, 'description': 'Hot coffee', 'imageUrl': '', 'stock': 100});
    await db.insert(tableProducts, {'id': 2, 'name': 'Sandwich', 'price': 8.99, 'cost': 4.0, 'sku': 'SAN001', 'barcode': '987654321', 'minStock': 5, 'description': 'Delicious sandwich', 'imageUrl': '', 'stock': 50});
    await db.insert(tableCustomers, {'id': 1, 'name': 'John Doe', 'phone': '1234567890', 'email': 'john@example.com', 'address': '123 Main St', 'loyaltyPoints': 0, 'creditBalance': 0.0});
    await db.insert(tableCategories, {'id': 1, 'name': 'Beverages', 'description': 'Drinks'});
    await db.insert(tableCategories, {'id': 2, 'name': 'Food', 'description': 'Food items'});
    await db.insert(tableSuppliers, {'id': 1, 'name': 'Local Supplier', 'contact': 'Supplier Contact', 'address': 'Supplier Address', 'phone': '0987654321', 'email': 'supplier@example.com'});
    await db.insert(tableEmployees, {'id': 1, 'name': 'Admin', 'role': 'admin', 'username': 'admin', 'password': 'admin123', 'isActive': 1});
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
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE $tableOrders ADD COLUMN paymentMethod TEXT DEFAULT "cash"');
    }
    if (oldVersion < 8) {
      // Add new columns to products
      await db.execute('ALTER TABLE $tableProducts ADD COLUMN cost REAL DEFAULT 0.0');
      await db.execute('ALTER TABLE $tableProducts ADD COLUMN sku TEXT');
      await db.execute('ALTER TABLE $tableProducts ADD COLUMN barcode TEXT');
      await db.execute('ALTER TABLE $tableProducts ADD COLUMN categoryId INTEGER');
      await db.execute('ALTER TABLE $tableProducts ADD COLUMN supplierId INTEGER');
      await db.execute('ALTER TABLE $tableProducts ADD COLUMN minStock INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE $tableProducts ADD COLUMN description TEXT');

      // Add new columns to customers
      await db.execute('ALTER TABLE $tableCustomers ADD COLUMN address TEXT');
      await db.execute('ALTER TABLE $tableCustomers ADD COLUMN loyaltyPoints INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE $tableCustomers ADD COLUMN creditBalance REAL DEFAULT 0.0');
      await db.execute('ALTER TABLE $tableCustomers ADD COLUMN dateOfBirth TEXT');
      await db.execute('ALTER TABLE $tableCustomers ADD COLUMN notes TEXT');

      // Add new columns to orders
      await db.execute('ALTER TABLE $tableOrders ADD COLUMN status INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE $tableOrders ADD COLUMN employeeId INTEGER');
      await db.execute('ALTER TABLE $tableOrders ADD COLUMN discount REAL DEFAULT 0.0');
      await db.execute('ALTER TABLE $tableOrders ADD COLUMN tax REAL DEFAULT 0.0');

      // Create new tables
      await db.execute('''
        CREATE TABLE $tableCategories(
          id INTEGER PRIMARY KEY,
          name TEXT,
          description TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE $tableSuppliers(
          id INTEGER PRIMARY KEY,
          name TEXT,
          contact TEXT,
          address TEXT,
          phone TEXT,
          email TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE $tableEmployees(
          id INTEGER PRIMARY KEY,
          name TEXT,
          role TEXT,
          username TEXT,
          password TEXT,
          isActive INTEGER DEFAULT 1
        )
      ''');
      await db.execute('''
        CREATE TABLE $tableStockTransactions(
          id INTEGER PRIMARY KEY,
          productId INTEGER,
          type INTEGER,
          quantity INTEGER,
          date TEXT,
          reason TEXT,
          employeeId INTEGER
        )
      ''');

      // Seed new data
      await db.insert(tableCategories, {'id': 1, 'name': 'Beverages', 'description': 'Drinks'});
      await db.insert(tableCategories, {'id': 2, 'name': 'Food', 'description': 'Food items'});
      await db.insert(tableSuppliers, {'id': 1, 'name': 'Local Supplier', 'contact': 'Supplier Contact', 'address': 'Supplier Address', 'phone': '0987654321', 'email': 'supplier@example.com'});
      await db.insert(tableEmployees, {'id': 1, 'name': 'Admin', 'role': 'admin', 'username': 'admin', 'password': 'admin123', 'isActive': 1});
    }
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
    final List<Map<String, dynamic>> orderMaps = await db.query(tableOrders);
    
    List<Order> orders = [];
    for (var map in orderMaps) {
      // Parse items
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

      // Fetch customer
      final customerMaps = await db.query(
        tableCustomers,
        where: 'id = ?',
        whereArgs: [map['customerId']],
      );
      
      Customer customer;
      if (customerMaps.isNotEmpty) {
        customer = Customer.fromMap(customerMaps.first);
      } else {
        customer = Customer(
          id: map['customerId'] as int,
          name: 'Guest',
          phone: '',
          email: '',
        );
      }

      // Parse payment method
      final paymentMethodStr = map['paymentMethod']?.toString() ?? 'cash';
      final paymentMethod = PaymentMethodExtension.fromString(paymentMethodStr);

      // Parse status
      final statusIndex = map['status'] ?? 0;
      final status = OrderStatus.values[statusIndex];

      orders.add(Order(
        id: map['id'],
        customer: customer,
        items: items,
        total: map['total'].toDouble(),
        date: DateTime.parse(map['date']),
        paymentMethod: paymentMethod,
        status: status,
        employeeId: map['employeeId'],
        discount: map['discount']?.toDouble() ?? 0.0,
        tax: map['tax']?.toDouble() ?? 0.0,
      ));
    }
    // Sort orders by date descending (latest first)
    orders.sort((a, b) => b.date.compareTo(a.date));
    return orders;
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
          'paymentMethod': order.paymentMethod.name,
          'status': order.status.index,
          'employeeId': order.employeeId,
          'discount': order.discount,
          'tax': order.tax,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {

      Get.snackbar('Error', 'Failed to save order: $e');
      rethrow;
    }
  }

  // Backup method: Use file_picker to save to user-selected file
  Future<String?> backupDatabase() async {
    try {
      // Request storage permissions
      if (Platform.isAndroid) {
        bool isAndroid11OrAbove = await _getAndroidApiLevel() >= 30;
        if (isAndroid11OrAbove) {
          final status = await Permission.manageExternalStorage.request();
          if (status.isDenied || status.isPermanentlyDenied) {
            if (status.isPermanentlyDenied) {
              await openAppSettings();
              Get.snackbar(
                'Error', // Error
                'Please grant "All files access" permission in settings.', // Please grant "All files access" permission
                snackPosition: SnackPosition.BOTTOM,
                duration: Duration(seconds: 5),
              );
              return null;
            }
            throw Exception('Manage external storage permission denied');
          }
        } else {
          final status = await Permission.storage.request();
          if (status.isDenied || status.isPermanentlyDenied) {
            if (status.isPermanentlyDenied) {
              await openAppSettings();
              Get.snackbar(
                'Error', // Error
                'Please grant storage permission in settings.', // Please grant storage permission
                snackPosition: SnackPosition.BOTTOM,
                duration: Duration(seconds: 5),
              );
              return null;
            }
            throw Exception('Storage permission denied');
          }
        }
      }

      final dbPath = await getDatabasesPath();
      final sourceFile = File(join(dbPath, dbName));

      if (!await sourceFile.exists()) {
        throw Exception('Database file not found');
      }

      // Read file as bytes
      final fileBytes = await sourceFile.readAsBytes();
      if (fileBytes.isEmpty) {
        throw Exception('Database file is empty');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final suggestedFileName = 'pos_backup_$timestamp.db';

      // Use file_picker to save file
      final result = await FilePicker.platform.saveFile(
        fileName: suggestedFileName,
        bytes: fileBytes,
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (result == null) {
        Get.snackbar('Error', 'No file location selected'); // No file location selected
        return null;
      }

      return result;
    } catch (e) {

      Get.snackbar('Error', 'Backup failed: $e');
      return null;
    }
  }

  // Restore method: Use file_picker to select backup file
  Future<bool> restoreDatabase(String backupFilePath) async {
    try {
      // Request read permission for the backup file
      if (Platform.isAndroid) {
        bool isAndroid11OrAbove = await _getAndroidApiLevel() >= 30;
        if (isAndroid11OrAbove) {
          final status = await Permission.manageExternalStorage.request();
          if (status.isDenied || status.isPermanentlyDenied) {
            if (status.isPermanentlyDenied) {
              await openAppSettings();
              Get.snackbar(
                'Error', // Error
                'Please grant "All files access" permission in settings.', // Please grant "All files access" permission
                snackPosition: SnackPosition.BOTTOM,
                duration: Duration(seconds: 5),
              );
              return false;
            }
            throw Exception('Manage external storage permission denied');
          }
        } else {
          final status = await Permission.storage.request();
          if (status.isDenied || status.isPermanentlyDenied) {
            if (status.isPermanentlyDenied) {
              await openAppSettings();
              Get.snackbar(
                'Error', // Error
                'Please grant storage permission in settings.', // Please grant storage permission
                snackPosition: SnackPosition.BOTTOM,
                duration: Duration(seconds: 5),
              );
              return false;
            }
            throw Exception('Storage permission denied');
          }
        }
      }

      final dbPath = await getDatabasesPath();
      final targetFile = File(join(dbPath, dbName));
      final sourceFile = File(backupFilePath);

      if (!await sourceFile.exists()) {
        throw Exception('Backup file not found or inaccessible'); // Backup file not found or inaccessible
      }

      // Validate file size
      final fileSize = await sourceFile.length();
      if (fileSize == 0) {
        throw Exception('Backup file is empty'); // Backup file is empty
      }

      // Validate database file before copying
      try {
        final tempDb = await openDatabase(sourceFile.path, readOnly: true);
        // Check if tables exist
        final tables = await tempDb.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
        if (!tables.any((table) => table['name'] == tableProducts) ||
            !tables.any((table) => table['name'] == tableCustomers) ||
            !tables.any((table) => table['name'] == tableOrders)) {
          await tempDb.close();
          throw Exception('Invalid database file'); // Invalid database file
        }
        await tempDb.close();
      } catch (e) {
        throw Exception('Invalid database file: $e'); // Invalid database file
      }

      // Close current DB
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // Replace DB
      await sourceFile.copy(targetFile.path);

      // Reopen DB
      _database = await _initDB();
      return true;
    } catch (e) {

      Get.snackbar('Error', 'Restore failed: $e');
      return false;
    }
  }

  // Helper to get Android API level
  Future<int> _getAndroidApiLevel() async {
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      return info.version.sdkInt;
    } catch (e) {
      return 0; // Default to 0 if unable to get API level
    }
  }

  // Category CRUD
  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableCategories);
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<void> addCategory(Category category) async {
    final db = await database;
    await db.insert(tableCategories, category.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateCategory(Category category) async {
    final db = await database;
    await db.update(
      tableCategories,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(int id) async {
    final db = await database;
    await db.delete(tableCategories, where: 'id = ?', whereArgs: [id]);
  }

  // Supplier CRUD
  Future<List<Supplier>> getSuppliers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableSuppliers);
    return List.generate(maps.length, (i) => Supplier.fromMap(maps[i]));
  }

  Future<void> addSupplier(Supplier supplier) async {
    final db = await database;
    await db.insert(tableSuppliers, supplier.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateSupplier(Supplier supplier) async {
    final db = await database;
    await db.update(
      tableSuppliers,
      supplier.toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
  }

  Future<void> deleteSupplier(int id) async {
    final db = await database;
    await db.delete(tableSuppliers, where: 'id = ?', whereArgs: [id]);
  }

  // Employee CRUD
  Future<List<Employee>> getEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableEmployees);
    return List.generate(maps.length, (i) => Employee.fromMap(maps[i]));
  }

  Future<void> addEmployee(Employee employee) async {
    final db = await database;
    await db.insert(tableEmployees, employee.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateEmployee(Employee employee) async {
    final db = await database;
    await db.update(
      tableEmployees,
      employee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  Future<void> deleteEmployee(int id) async {
    final db = await database;
    await db.delete(tableEmployees, where: 'id = ?', whereArgs: [id]);
  }

  // Stock Transaction CRUD
  Future<List<StockTransaction>> getStockTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableStockTransactions);
    return List.generate(maps.length, (i) => StockTransaction.fromMap(maps[i]));
  }

  Future<void> addStockTransaction(StockTransaction transaction) async {
    final db = await database;
    await db.insert(tableStockTransactions, transaction.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> debugSchema() async {
    final db = await database;
    await db.rawQuery('PRAGMA table_info($tableOrders)');
  }
}
