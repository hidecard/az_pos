import 'dart:convert';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../utils/printer_config.dart';

class BluetoothPrinterService extends GetxService {
  final PrinterManager printerManager = PrinterManager.instance;
  final RxList<PrinterDevice> devices = <PrinterDevice>[].obs;
  final Rx<PrinterDevice?> connectedDevice = Rx<PrinterDevice?>(null);
  final RxBool isConnected = false.obs;

  Future<void> init() async {
    try {
      await printerManager.startScan(Duration(seconds: 4));
      printerManager.scanResults.listen((devices) {
        this.devices.value = devices;
      });
    } catch (e) {
      print('Bluetooth init error: $e');
    }
  }

  Future<void> getDevices() async {
    try {
      await printerManager.startScan(Duration(seconds: 4));
    } catch (e) {
      print('Error getting devices: $e');
    }
  }

  Future<bool> connect(PrinterBluetooth device) async {
    try {
      await printerManager.connect(device);
      connectedDevice.value = device;
      isConnected.value = true;
      return true;
    } catch (e) {
      print('Connection error: $e');
      isConnected.value = false;
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await printerManager.disconnect();
      connectedDevice.value = null;
      isConnected.value = false;
    } catch (e) {
      print('Disconnect error: $e');
    }
  }

  Future<void> printInvoice(PrinterConfig config, {required String customerName, required String phone}) async {
    if (!isConnected.value) {
      throw Exception('Printer not connected');
    }

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      bytes += generator.text('MY SHOP',
          styles: PosStyles(align: PosAlign.center, height: PosTextSize.size2, width: PosTextSize.size2));
      bytes += generator.text('INVOICE',
          styles: PosStyles(align: PosAlign.center, height: PosTextSize.size1, width: PosTextSize.size1));
      bytes += generator.feed(1);

      final now = DateTime.now();
      bytes += generator.text('Invoice No: ${now.millisecondsSinceEpoch}');
      bytes += generator.text('Date: ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}');
      bytes += generator.feed(1);

      bytes += generator.text('Customer: $customerName');
      bytes += generator.text('Phone: $phone');
      bytes += generator.feed(1);

      bytes += generator.text('Product          Qty  Price  Total');
      bytes += generator.text('-' * 32);

      for (var item in config.cartController.cartItems) {
        final name = item.product.name.length > 15 ? item.product.name.substring(0, 15) : item.product.name.padRight(15);
        final qty = item.quantity.toString().padLeft(3);
        final price = item.product.price.toStringAsFixed(2).padLeft(6);
        final total = item.total.toStringAsFixed(2).padLeft(6);
        bytes += generator.text('$name $qty $price $total');
      }

      bytes += generator.text('-' * 32);
      final totalAmountStr = config.cartController.totalAmount.value.toStringAsFixed(2);
      bytes += generator.text('Total: $totalAmountStr MMK', styles: PosStyles(bold: true));
      bytes += generator.feed(1);

      bytes += generator.text('Thank you for your purchase!',
          styles: PosStyles(align: PosAlign.center, height: PosTextSize.size1, width: PosTextSize.size1));
      bytes += generator.feed(2);
      bytes += generator.cut();

      bluetooth.paperCut();

    } catch (e) {
      print('Print error: $e');
      throw Exception('Failed to print: $e');
    }
  }
}
