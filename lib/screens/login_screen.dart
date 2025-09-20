// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:az_pos/screens/home_screen.dart';
// import 'package:az_pos/controllers/auth_controller.dart';
// import 'package:google_fonts/google_fonts.dart';

// class LoginScreen extends StatelessWidget {
//   final AuthController authController = Get.put(AuthController());
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: EdgeInsets.all(32),
//         child: Card(
//           elevation: 8,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           child: Padding(
//             padding: EdgeInsets.all(32),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'POS Login',
//                     style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 32),
//                   TextFormField(
//                     controller: _usernameController,
//                     decoration: InputDecoration(
//                       labelText: 'Username',
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                     style: GoogleFonts.roboto(),
//                     validator: (value) => value!.isEmpty ? 'Enter username' : null,
//                   ),
//                   SizedBox(height: 16),
//                   TextFormField(
//                     controller: _passwordController,
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                     style: GoogleFonts.roboto(),
//                     obscureText: true,
//                     validator: (value) => value!.isEmpty ? 'Enter password' : null,
//                   ),
//                   SizedBox(height: 32),
//                   ElevatedButton(
//                     onPressed: () async {
//                       if (_formKey.currentState!.validate()) {
//                         final success = await authController.login(
//                           _usernameController.text,
//                           _passwordController.text,
//                         );
//                         if (success) {
//                           Get.offAll(() => ());
//                         } else {
//                           Get.snackbar(
//                             'Error',
//                             'Invalid username or password',
//                             snackPosition: SnackPosition.BOTTOM,
//                           );
//                         }
//                       }
//                     },
//                     child: Text(
//                       'Login',
//                       style: GoogleFonts.roboto(fontSize: 16),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: Size(double.infinity, 50),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }