// ignore_for_file: use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinalprojectbark/pages/login_page.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:logging/logging.dart';
import 'package:pinalprojectbark/design.dart';

final Logger _logger = Logger('RegisterPage'); // Create a logger instance

class RegisterPage extends StatefulWidget {
  final token;
  const RegisterPage({@required this.token, super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isNotValidate = false;
  String _selectedRole = 'בעלים'; // Default role

  void registerUser() async {
    if (emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        userNameController.text.isNotEmpty) {
      var regBody = {
        "userName": userNameController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "role": _selectedRole == 'בעלים' ? 'owner' : 'trainer',
      };

      var response = await http.post(
        Uri.parse(registeration),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      var jsonResponse = jsonDecode(response.body);

      _logger.info('Status: ${jsonResponse['status']}');

      if (jsonResponse['status']) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return LoginPage(token: widget.token);
          }),
        );
      } else {
        _logger.warning("משהו השתבש");
      }
    } else {
      setState(() {
        _isNotValidate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Background container with rounded bottom corners
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100),
                ),
              ),
            ),
          ),
          // Content on top of the background
          Positioned(
            top: 50, // Position the logo inside the blue container
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Logo
                Image.asset(
                  "assets/images/logoMe.png", // updated path
                  height: 180,
                  width: 180,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'הרשמה',
                    style: TextStyle(
                      fontFamily: 'Rubik', // פונט לכותרות
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Name Field
                  TextFormField(
                    controller: userNameController,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'הכנס את שם משתמש',
                      hintStyle: const TextStyle(
                        fontFamily: 'OpenSans', // פונט לטקסטים רגילים
                        color: AppColors.textColor,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundColor,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Iconsax.user,
                          color: AppColors.accentColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Email Field
                  TextFormField(
                    controller: emailController,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'הכנס את האימייל',
                      hintStyle: const TextStyle(
                        fontFamily: 'OpenSans', // פונט לטקסטים רגילים
                        color: AppColors.textColor,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundColor,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Iconsax.message,
                          color: AppColors.accentColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Password Field
                  TextFormField(
                    controller: passwordController,
                    textAlign: TextAlign.right,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'הכנס את הסיסמה',
                      hintStyle: const TextStyle(
                        fontFamily: 'OpenSans', // פונט לטקסטים רגילים
                        color: AppColors.textColor,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundColor,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Iconsax.lock,
                          color: AppColors.accentColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Role Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedRole = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.backgroundColor,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon:
                          const Icon(Iconsax.add, color: AppColors.accentColor),
                    ),
                    items: <String>['בעלים', 'מאלף'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            value,
                            style: const TextStyle(
                              fontFamily: 'OpenSans', // פונט לטקסטים ברשימה
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // Terms & Conditions Checkbox
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'אני מסכים לתנאים ולהגבלות',
                        style: TextStyle(
                          fontFamily: 'OpenSans', // פונט לטקסטים רגילים
                          fontSize: 12,
                          color: AppColors.textColor,
                        ),
                      ),
                      Checkbox(
                        value: _isNotValidate,
                        onChanged: (value) {
                          setState(() {
                            _isNotValidate = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: registerUser,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: AppColors.secondaryColor,
                      ),
                      child: const Text(
                        'הרשמה',
                        style: TextStyle(
                          fontFamily: 'Alef', // פונט לכפתור
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Sign In Button
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  LoginPage(token: widget.token)),
                        );
                      },
                      child: const Text(
                        'כבר רשום? התחבר',
                        style: TextStyle(
                          fontFamily: 'OpenSans', // פונט לטקסטים רגילים
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
