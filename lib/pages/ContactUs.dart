// ignore_for_file: use_build_context_synchronously, prefer_typing_uninitialized_variables, file_names, unused_element, prefer_final_fields

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:pinalprojectbark/design.dart';
import 'package:pinalprojectbark/pages/config.dart';

final Logger _logger = Logger('ProfilePage');

class ContactUs extends StatefulWidget {
  final token;
  final String userId, userName, roleU;
  const ContactUs(
      {@required this.token,
      required this.roleU,
      required this.userId,
      required this.userName,
      super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _messageController = TextEditingController();

  String translateRole(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return 'בעלים';
      case 'trainer':
        return 'מאלף';
      default:
        return role; // return the original if no match is found
    }
  }

  void sendMessage(
      String userId, String userName, String roleU, String message) async {
    String userAdminId = "65c7b99e258a75cc2293f8a1";
    String admin = "Admin";
    try {
      final response = await http.post(
        Uri.parse(sendMessageUserToAdmin),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "adminId": userAdminId,
          "adminUsername": admin,
          "userId": userId,
          "recipientUsername": userName,
          "recipientType": roleU,
          "message": message,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully')),
        );
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception('Failed to send message: ${errorResponse['error']}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to send message. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String translatedRole = translateRole(widget.roleU);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'צור קשר עם מנהל',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Rubik',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.message),
            ),
          ],
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'שם:',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Alef',
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: widget.userName,
                              readOnly: true,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.backgroundColor,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                    color: AppColors.accentColor,
                                    width: 2.0,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                    color: AppColors.accentColor,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Alef',
                                color: AppColors.textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'תפקיד:',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Alef',
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: translatedRole,
                              readOnly: true,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.backgroundColor,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                    color: AppColors.accentColor,
                                    width: 2.0,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                    color: AppColors.accentColor,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Alef',
                                color: AppColors.textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'הודעה:',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Alef',
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _messageController,
                              textAlign: TextAlign.right,
                              maxLines: 6,
                              decoration: InputDecoration(
                                hintText: 'כתוב את הודעתך כעת',
                                hintStyle: const TextStyle(
                                  fontFamily: 'Alef',
                                  color: AppColors.textColor,
                                ),
                                filled: true,
                                fillColor: AppColors.backgroundColor,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                    color: AppColors.accentColor,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Alef',
                                color: AppColors.textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            sendMessage(
                              widget.userId,
                              widget.userName,
                              widget.roleU,
                              _messageController.text,
                            );
                            _messageController.clear();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: AppColors.primaryColor,
                        ),
                        child: const Text(
                          'שלח',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Rubik',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
