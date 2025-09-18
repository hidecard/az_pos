import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../controllers/product_controller.dart';
import '../controllers/customer_controller.dart';
import '../controllers/order_controller.dart';

class BackupRestoreScreen extends StatefulWidget {
  @override
  _BackupRestoreScreenState createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final DatabaseService _dbService = DatabaseService();
  bool _encryptBackup = false;

  @override
  void initState() {
    super.initState();
    _loadEncryptionSetting();
  }

  Future<void> _loadEncryptionSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _encryptBackup = prefs.getBool('encryptBackup') ?? false;
    });
  }

  Future<void> _saveEncryptionSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('encryptBackup', value);
    setState(() {
      _encryptBackup = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Backup & Restore')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final backupPath = await _dbService.backupDatabase(encryptBackup: _encryptBackup);
                if (backupPath != null) {
                  Get.snackbar(
                    'Success',
                    'Backup created at: $backupPath',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: Duration(seconds: 3),
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    'Backup failed. Check permissions or try again.',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: Duration(seconds: 5),
                  );
                }
              },
              icon: Icon(Icons.backup),
              label: Text('Create Backup'),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['db', 'enc'],
                );
                if (result != null && result.files.single.path != null) {
                  final bool isEncrypted = result.files.single.extension == 'enc';
                  final success = await _dbService.restoreDatabase(
                    result.files.single.path!,
                    isEncrypted: isEncrypted,
                  );
                  if (success) {
                    Get.snackbar(
                      'Success',
                      'Database restored. App will reload data.',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: Duration(seconds: 3),
                    );
                    Get.find<ProductController>().loadProducts();
                    Get.find<CustomerController>().loadCustomers();
                    Get.find<OrderController>().loadOrders();
                  } else {
                    Get.snackbar(
                      'Error',
                      'Restore failed. Check file or permissions.',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: Duration(seconds: 5),
                    );
                  }
                } else {
                  Get.snackbar(
                    'Error',
                    'No file selected',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: Duration(seconds: 3),
                  );
                }
              },
              icon: Icon(Icons.restore),
              label: Text('Restore from Backup'),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Encrypt Backups'),
              value: _encryptBackup,
              onChanged: (value) async {
                await _saveEncryptionSetting(value);
                Get.snackbar(
                  'Info',
                  'Encryption toggled: $value',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: Duration(seconds: 3),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}