import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import 'dart:convert';
import 'dart:typed_data';

class DatabaseService {
  static Database? _database;
  static const String tableProducts = 'products';
  static const String tableCustomers = 'customers';
  static const String tableOrders = 'orders';
  static const String dbName = 'pos.db';
  static const String secretKey = 'MySecretPOSKey2025!@#\$%^&*()_+-='; // Exactly 32 bytes
  static const String ivString = 'My16ByteIVString'; // Exactly 16 bytes for AES

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), dbName);
    return await openDatabase(
      path,
      version: 6,
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
      Get.snackbar('Error', 'Failed to save order: $e');
      rethrow;
    }
  }

  // Backup method: Use file_picker to save to user-selected file
  Future<String?> backupDatabase({bool encryptBackup = false}) async {
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
                'Error',
                'Please grant "All files access" permission in Settings',
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
                'Error',
                'Please grant storage permission in Settings',
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
      final suggestedFileName = encryptBackup ? 'pos_backup_$timestamp.enc' : 'pos_backup_$timestamp.db';

      // Prepare bytes for saving
      Uint8List bytesToSave;
      if (encryptBackup) {
        final key = encrypt.Key.fromUtf8(secretKey); // 32 bytes
        final iv = encrypt.IV.fromUtf8(ivString); // 16 bytes
        final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
        final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);
        bytesToSave = encrypted.bytes;
      } else {
        bytesToSave = fileBytes;
      }

      // Use file_picker to save file
      final result = await FilePicker.platform.saveFile(
        fileName: suggestedFileName,
        bytes: bytesToSave,
        type: FileType.custom,
        allowedExtensions: encryptBackup ? ['enc'] : ['db'],
      );

      if (result == null) {
        Get.snackbar('Error', 'No file location selected');
        return null;
      }

      return result;
    } catch (e) {
      print('Backup error: $e');
      Get.snackbar('Error', 'Backup failed: $e');
      return null;
    }
  }

  // Restore method: Use file_picker to select backup file
  Future<bool> restoreDatabase(String backupFilePath, {bool isEncrypted = false}) async {
    try {
      final dbPath = await getDatabasesPath();
      final targetFile = File(join(dbPath, dbName));
      File sourceFile = File(backupFilePath);

      if (!await sourceFile.exists()) {
        throw Exception('Backup file not found');
      }

      // Decrypt if needed
      if (isEncrypted) {
        final key = encrypt.Key.fromUtf8(secretKey); // 32 bytes
        final iv = encrypt.IV.fromUtf8(ivString); // 16 bytes
        final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
        final encryptedContent = await sourceFile.readAsBytes();
        final decryptedBytes = encrypter.decryptBytes(encrypt.Encrypted(encryptedContent), iv: iv);
        final tempFile = File(join(dbPath, 'temp_restore.db'));
        await tempFile.writeAsBytes(decryptedBytes);
        sourceFile = tempFile;
      }

      // Close current DB
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // Replace DB
      await sourceFile.copy(targetFile.path);

      // Clean up temp file
      if (isEncrypted && await sourceFile.exists()) {
        await sourceFile.delete();
      }

      // Reopen DB
      _database = await _initDB();
      return true;
    } catch (e) {
      print('Restore error: $e');
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

  Future<void> debugSchema() async {
    final db = await database;
    final result = await db.rawQuery('PRAGMA table_info($tableOrders)');
    print('Orders table schema: $result');
  }
}