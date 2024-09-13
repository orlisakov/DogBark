// ignore_for_file: file_names, use_build_context_synchronously, prefer_typing_uninitialized_variables
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pinalprojectbark/components/my_list_tile.dart';
import 'package:pinalprojectbark/constants/helper_functions.dart';
import 'package:pinalprojectbark/constants/image_strings.dart';
import 'package:pinalprojectbark/pages/config.dart';
import 'package:pinalprojectbark/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageAdmin extends StatefulWidget {
  final token;
  const HomePageAdmin({@required this.token, super.key});

  @override
  State<HomePageAdmin> createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  late SharedPreferences prefs;
  late String email, role, id;
  List<Map<String, dynamic>> trainers = [];
  List<Map<String, dynamic>> owners = [];
  List<Map<String, dynamic>> users = [];

  //-----------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    if (widget.token == null || widget.token!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(token: widget.token),
          ),
          (Route<dynamic> route) => false,
        );
      });
    } else {
      Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
      role = jwtDecodedToken['role'] ?? '';
      email = jwtDecodedToken['email'] ?? '';
      id = jwtDecodedToken['_id'] ?? '';
      initSharedPref();
      fetchUsers(); // Fetch users when the page initializes
    }
  }

  //-----------------------------------------------------------------------
  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  //-----------------------------------------------------------------------
  void fetchUsers() async {
    try {
      // Fetch trainers
      final trainersResponse = await http.get(
        Uri.parse(getTrainers),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      // Fetch owners
      final ownersResponse = await http.get(
        Uri.parse(getOwners),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (trainersResponse.statusCode == 200 &&
          ownersResponse.statusCode == 200) {
        List<dynamic> trainersData = json.decode(trainersResponse.body);
        List<dynamic> ownersData = json.decode(ownersResponse.body);
        setState(() {
          trainers = List<Map<String, dynamic>>.from(trainersData);
          owners = List<Map<String, dynamic>>.from(ownersData);
          users = [...trainers, ...owners];
        });
      } else {
        throw Exception('Failed to fetch users');
      }
    } catch (e) {
      //print('Error fetching users: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'Failed to fetch users. Please check your network connection and try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  //-----------------------------------------------------------------------
  void deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse(deleteUserByAdmin),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json", // Specify content type
        },
        // Convert the userId to JSON and send in the body
        body: json.encode({"userId": userId}),
      );

      if (response.statusCode == 200) {
        // Successful deletion, refresh user list
        fetchUsers();
      } else {
        // Handle unsuccessful deletion
        throw Exception('Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      //print('Error deleting user: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'Failed to delete user. Please check your network connection and try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  //-----------------------------------------------------------------------
  void sendMessageToUser(
      String userId, String userName, String roleU, String message) async {
    try {
      final response = await http.post(
        Uri.parse(sendMessageAdminToUser),
        headers: {
          "Authorization":
              "Bearer ${widget.token}", // Ensure widget.token is correct
          "Content-Type": "application/json",
        },
        body: json.encode({
          "adminId": id,
          "adminUsername": role,
          "userId": userId,
          "recipientUsername": userName,
          "recipientType": roleU,
          "message": message,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent successfully'),
          ),
        );
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception('Failed to send message: ${errorResponse['error']}');
      }
    } catch (e) {
      String errorMessage = 'Failed to send message. Please try again later.';
      if (e is SocketException) {
        errorMessage = 'Please check your network connection and try again.';
      } else {
        errorMessage = 'An error occurred: ${e.toString()}';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('שגיאה'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('אוקי'),
            ),
          ],
        ),
      );
      //print('Error sending message: $e');
    }
  }

  //-----------------------------------------------------------------------
  void logout() async {
    // Assuming you also want to clear the shared preferences upon logout
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(token: widget.token),
      ),
      (Route<dynamic> route) => false,
    );
  }

  //-----------------------------------------------------------------------
  void goToMessages() {
    // Implement the navigation to the messages page here.
    // Navigator.push(context, MaterialPageRoute(builder: (context) => MessagesPage(token: widget.token)));
    // The above line is an example. Replace MessagesPage with your actual page class.
  }

  //-----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "$role שלום",
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white),
            ),
            IconButton(
              onPressed: logout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 66, 159, 236),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Text(
                          'בעלים',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: owners.length,
                      itemBuilder: (context, index) {
                        final user = owners[index];
                        return ListTile(
                          title: Text(user['userName'] ?? 'Unknown'),
                          subtitle: Text(user['email'] ?? 'No email'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('מחיקת משתמש'),
                                      content: const Text(
                                          'Are you sure you want to delete this user?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('יציאה'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            deleteUser(user['_id']);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('מחק'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.message),
                                onPressed: () {
                                  String message =
                                      ''; // Initialize message variable
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('שלח הודעה'),
                                      content: StatefulBuilder(
                                        builder: (context, setState) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextField(
                                                onChanged: (value) {
                                                  setState(() {
                                                    message = value;
                                                  });
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                  labelText:
                                                      'הזן את ההודעה כעת',
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('יציאה'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      sendMessageToUser(
                                                        user['_id'],
                                                        user['userName'],
                                                        user['role'],
                                                        message,
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('שלח'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Text(
                          'מאלפים',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: trainers.length,
                      itemBuilder: (context, index) {
                        final user = trainers[index];
                        return ListTile(
                          title: Text(user['userName'] ?? 'Unknown'),
                          subtitle: Text(user['email'] ?? 'No email'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('מחק משתמש'),
                                      content: const Text(
                                          'Are you sure you want to delete this user?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('יציאה'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            deleteUser(user['_id']);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('אישור'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.message),
                                onPressed: () {
                                  String message =
                                      ''; // Initialize message variable
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('שליחת הודעה'),
                                      content: StatefulBuilder(
                                        builder: (context, setState) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextField(
                                                onChanged: (value) {
                                                  setState(() {
                                                    message = value;
                                                  });
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                  labelText:
                                                      'Enter your message',
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      sendMessageToUser(
                                                        user['_id'],
                                                        user['userName'],
                                                        user['role'],
                                                        message,
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('שלח'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const SizedBox(height: 80),
                Image(
                  height: 150,
                  image: AssetImage(
                    dark ? TImages.lightAppLogo : TImages.darkAppLogo,
                  ),
                ),
                MyListTile(
                  icon: Icons.home,
                  text: 'ב י ת',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: MyListTile(
                icon: Icons.logout,
                text: 'ה ת נ ת ק ו ת',
                onTap: logout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
