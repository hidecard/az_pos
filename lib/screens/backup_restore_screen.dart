import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';
import '../controllers/product_controller.dart';
import '../controllers/customer_controller.dart';
import '../controllers/order_controller.dart';

class BackupRestoreScreen extends StatelessWidget {
  BackupRestoreScreen({super.key});

  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Backup & Restore',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Database Management',
                  style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final backupPath = await _dbService.backupDatabase();
                      if (backupPath != null) {
                        Get.snackbar(
                          'Success',
                          'Backup file created: $backupPath',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: Duration(seconds: 3),
                        );
                      } else {
                        Get.snackbar(
                          'Error',
                          'Backup failed. Check permissions and try again.',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: Duration(seconds: 5),
                        );
                      }
                    } catch (e) {
                      print('Backup error: $e');
                      Get.snackbar(
                        'Error',
                        'Backup failed: $e',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: Duration(seconds: 5),
                      );
                    }
                  },
                  icon: Icon(Icons.backup, size: 24),
                  label: Text(
                    'Create Backup',
                    style: GoogleFonts.roboto(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.any,
                        allowMultiple: false,
                      );
                      if (result == null || result.files.isEmpty || result.files.single.path == null) {
                        Get.snackbar(
                          'Error',
                          'No valid file selected',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: Duration(seconds: 3),
                        );
                        return;
                      }

                      final filePath = result.files.single.path!;
                      print('Selected file path: $filePath'); // Debug log
                      if (!filePath.toLowerCase().endsWith('.db')) {
                        Get.snackbar(
                          'Error',
                          'Selected file must be a .db file',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: Duration(seconds: 5),
                        );
                        return;
                      }

                      final success = await _dbService.restoreDatabase(filePath);
                      if (success) {
                        Get.snackbar(
                          'Success',
                          'Database restored successfully. App data will reload.',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: Duration(seconds: 3),
                        );
                        Get.find<ProductController>().loadProducts();
                        Get.find<CustomerController>().loadCustomers();
                        Get.find<OrderController>().loadOrders();
                      } else {
                        Get.snackbar(
                          'Error',
                          'Restore failed. Check file validity and permissions.',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: Duration(seconds: 5),
                        );
                      }
                    } catch (e) {
                      print('Restore error: $e');
                      Get.snackbar(
                        'Error',
                        'Restore failed: $e',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: Duration(seconds: 5),
                      );
                    }
                  },
                  icon: Icon(Icons.restore, size: 24),
                  label: Text(
                    'Restore from Backup',
                    style: GoogleFonts.roboto(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}