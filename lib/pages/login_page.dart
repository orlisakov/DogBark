// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pinalprojectbark/design.dart';
import 'package:pinalprojectbark/pages/Admin/homePageAdmin.dart';
import 'package:pinalprojectbark/pages/Trainer/homePageTrainer.dart';
import 'package:pinalprojectbark/pages/owner/homePageOwner.dart';
import 'package:pinalprojectbark/pages/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'config.dart';

final Logger _logger = Logger('LoginPage');

class LoginPage extends StatefulWidget {
  final token;
  const LoginPage({@required this.token, super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late SharedPreferences prefs;
  late String role;

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void loginUser() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      var reqBody = {
        "email": emailController.text,
        "password": passwordController.text
      };

      var response = await http.post(
        Uri.parse(login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status']) {
        var token = jsonResponse['token'];
        await prefs.setString('token', token);

        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        role = decodedToken['role'];

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            if (role == 'owner') {
              return HomePageOwner(token: token);
            } else if (role == 'trainer') {
              return HomePageTrainer(token: token);
            } else {
              return HomePageAdmin(token: token);
            }
          }),
        );
      } else {
        _logger.warning('Something went wrong');
      }
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
            top: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Logo
                Image.asset(
                  "assets/images/logoMe.png",
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    "!ברוך הבא, התגעגענו אליך",
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: emailController,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'הכנס את האימייל',
                      hintStyle: const TextStyle(
                        fontFamily: 'OpenSans',
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
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    textAlign: TextAlign.right,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'הכנס את הסיסמה',
                      hintStyle: const TextStyle(
                        fontFamily: 'OpenSans',
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
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loginUser,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: AppColors.secondaryColor,
                      ),
                      child: const Text(
                        'התחבר',
                        style: TextStyle(
                          fontFamily: 'Alef',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  RegisterPage(token: widget.token)),
                        );
                      },
                      child: const Text(
                        "!עדיין לא נרשמת? הירשם עכשיו",
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 16,
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
