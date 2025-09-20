// import 'package:get/Get.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class AuthController extends GetxController {
//   final FlutterSecureStorage _storage = FlutterSecureStorage();
//   final String _passwordKey = 'app_password';

//   Future<void> initPassword() async {
//     String? storedPassword = await _storage.read(key: _passwordKey);
//     if (storedPassword == null) {
//       await _storage.write(key: _passwordKey, value: 'admin');
//     }
//   }

//   Future<bool> login(String username, String password) async {
//     await initPassword();
//     String? storedPassword = await _storage.read(key: _passwordKey);
//     return username == 'admin@gmail.com' && password == storedPassword;
//   }

//   Future<void> changePassword(String newPassword) async {
//     await _storage.write(key: _passwordKey, value: newPassword);
//   }
// }