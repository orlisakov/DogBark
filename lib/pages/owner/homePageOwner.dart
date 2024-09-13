// ignore_for_file: file_names, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pinalprojectbark/components/my_list_tile.dart';
import 'package:pinalprojectbark/constants/helper_functions.dart';
import 'package:pinalprojectbark/constants/image_strings.dart';
import 'package:pinalprojectbark/design.dart';
import 'package:pinalprojectbark/pages/ContactUs.dart';
import 'package:pinalprojectbark/pages/config.dart';
import 'package:pinalprojectbark/pages/login_page.dart';
import 'package:pinalprojectbark/pages/owner/MyTrainingProcesses.dart';
import 'package:pinalprojectbark/pages/owner/profilePageOwner.dart';
import 'package:pinalprojectbark/pages/owner/searchDogTrainers.dart';
import 'package:pinalprojectbark/pages/owner/trainerProfileScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;
import 'AppointmentsPage.dart';

class HomePageOwner extends StatefulWidget {
  final String token;
  const HomePageOwner({required this.token, Key? key}) : super(key: key);

  @override
  State<HomePageOwner> createState() => _HomePageOwnerState();
}

class _HomePageOwnerState extends State<HomePageOwner> {
  late String email, userName, ownerId, role;
  late Future<List<Post>> _posts;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _posts = fetchPosts(widget.token);
  }

  void _loadUserData() {
    if (widget.token.isNotEmpty) {
      final jwtDecodedToken = JwtDecoder.decode(widget.token);
      ownerId = jwtDecodedToken['_id'];
      if (mounted) {
        setState(() {
          email = jwtDecodedToken['email'] ?? '';
          userName = jwtDecodedToken['userName'] ?? '';
          role = jwtDecodedToken['role'] ?? '';
        });
      }
    }
  }

  Future<List<Post>> fetchPosts(String token) async {
    try {
      final response = await http.get(
        Uri.parse(getPosts),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['posts'] is List) {
          final List<dynamic> postsData = jsonResponse['posts'];

          return postsData.map((data) {
            return Post.fromJson(data as Map<String, dynamic>);
          }).toList();
        } else {
          throw Exception('Invalid response format: "posts" is not a list');
        }
      } else {
        print('Error fetching posts: ${response.reasonPhrase}');
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      print('Exception in fetchPosts: $e');
      throw Exception('Failed to load posts');
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage(token: widget.token)),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<List<dynamic>> fetchUserMessages(String userId) async {
    final response = await http.get(
      Uri.parse('$getMessagesForUser/$userId'),
      headers: {
        "Authorization": "Bearer ${widget.token}",
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse is Map<String, dynamic> &&
          jsonResponse.containsKey('success')) {
        return jsonResponse['success'];
      } else {
        throw Exception(
            'Unexpected JSON structure: Expected object with "success" key');
      }
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Widget setupDialogContainer(List<dynamic> messages) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: messages.length,
          itemBuilder: (BuildContext context, int index) {
            var message = messages[index];
            return ListTile(
              title: Text("הודעה מהמאלף: ${message['trainerName']}",
                  style: const TextStyle(fontSize: 18)),
              subtitle: Text(message['message']),
            );
          },
        ),
      ),
    );
  }

  Future<void> showMessagesDialog() async {
    try {
      final messages = await fetchUserMessages(ownerId);
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Align(
                alignment: Alignment.centerRight,
                child: Text('הודעות חדשות'),
              ),
              content: setupDialogContainer(messages),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load messages: $e')),
        );
      }
    }
  }

  Future<Map<String, dynamic>> fetchTrainerProfile(String trainerId) async {
    final Uri apiUri = Uri.parse('$getTrainerProfileByDogId/$trainerId');

    final response = await http.get(
      apiUri,
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (response.statusCode == 200) {
      final responseBody = response.body;

      final jsonResponse = json.decode(responseBody);
      if (jsonResponse is List && jsonResponse.isNotEmpty) {
        final trainerProfile = jsonResponse.first;
        if (trainerProfile is Map<String, dynamic>) {
          return trainerProfile;
        } else {
          throw Exception(
              'Invalid JSON structure: Expected object with trainer profile data');
        }
      } else {
        throw Exception(
            'Invalid JSON structure: Expected a non-empty list with trainer profile data');
      }
    } else {
      throw Exception('Failed to load trainer profile');
    }
  }

  void showCustomMessagePopup(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                    fontFamily: 'Rubik',
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  message,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textColor,
                    fontFamily: 'Alef',
                  ),
                ),
                const SizedBox(height: 15.0),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "שלום $userName",
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications,
                color: Colors.black,
              ),
              onPressed: () async {
                try {
                  final messages = await fetchUserMessages(ownerId);
                  if (messages.isEmpty) {
                    showCustomMessagePopup(
                        context, 'הודעות חדשות', 'אין הודעות מהשבוע האחרון');
                  } else {
                    showCustomMessagePopup(
                        context, 'הודעות חדשות', 'יש לך הודעות חדשות');
                  }
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $error'),
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.black,
              ),
              onPressed: logout,
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: AppColors.primaryColor.withOpacity(0.8),
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
                    text: 'בית',
                    onTap: () => Navigator.pop(context),
                  ),
                  MyListTile(
                    icon: Icons.person,
                    text: 'פרופיל',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfilePageOwner(token: widget.token),
                      ),
                    ),
                  ),
                  MyListTile(
                    icon: Icons.search,
                    text: 'חיפוש מאלפים',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DogTrainerSearchPage(token: widget.token),
                      ),
                    ),
                  ),
                  MyListTile(
                    icon: Icons.access_alarm_outlined,
                    text: 'תהליכי אילוף',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MyTrainingProcesses(token: widget.token)),
                    ),
                  ),
                  MyListTile(
                    icon: Icons.calendar_today,
                    text: 'הפגישות שלי',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppointmentsPage(
                          token: widget.token,
                          ownerId: ownerId,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    MyListTile(
                      icon: Icons.sports_kabaddi,
                      text: 'צור קשר',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactUs(
                            token: widget.token,
                            userId: ownerId,
                            userName: userName,
                            roleU: role,
                          ),
                        ),
                      ),
                    ),
                    MyListTile(
                      icon: Icons.logout,
                      text: 'התנתקות',
                      onTap: logout,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 20),
              // Posts Section
              FutureBuilder<List<Post>>(
                future: _posts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final post = snapshot.data![index];
                        final time =
                            intl.DateFormat('HH:mm').format(post.createdAt);
                        final date =
                            intl.DateFormat('dd.MM').format(post.createdAt);
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColor,
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: post.profilePicture !=
                                            'default_id'
                                        ? NetworkImage(
                                            'http://192.168.70.1:3000/${post.profilePicture}')
                                        : const AssetImage(
                                                'assets/images/logoMe.png')
                                            as ImageProvider,
                                    radius: 25.0,
                                    backgroundColor: AppColors.accentColor,
                                  ),
                                  const SizedBox(width: 10.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          final trainerProfile =
                                              await fetchTrainerProfile(
                                                  post.trainerId);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TrainerProfileScreen(
                                                trainerData: trainerProfile,
                                                token: widget.token,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          post.trainerName,
                                          style: const TextStyle(
                                            color: AppColors.secondaryColor,
                                            fontFamily: 'Rubik',
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        '$time, $date',
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          color: AppColors.textColor,
                                          fontFamily: 'Alef',
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                post.content,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'Alef',
                                  color: AppColors.textColor,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 8.0),
                              if (post.media.isNotEmpty)
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: post.media.length,
                                    itemBuilder: (context, mediaIndex) {
                                      final mediaUrl = post.media[mediaIndex];
                                      return Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          child: Image.network(
                                            'http://192.168.70.1:3000/$mediaUrl',
                                            fit: BoxFit.cover,
                                            width: 100,
                                            height: 100,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(
                                                  Icons.broken_image,
                                                  size: 50);
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No posts available.'));
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.search),
                color: AppColors.accentColor,
                iconSize: 40.0,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DogTrainerSearchPage(token: widget.token),
                  ),
                ),
              ),
              const Text(
                'חפש מאלף',
                style: TextStyle(
                  color: AppColors.textColor,
                  fontFamily: 'Alef',
                ),
              ),
            ],
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.access_alarm_outlined),
                color: AppColors.accentColor,
                iconSize: 40.0,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MyTrainingProcesses(token: widget.token)),
                ),
              ),
              const Text(
                'תהליכי אילוף',
                style: TextStyle(
                  color: AppColors.textColor,
                  fontFamily: 'Alef',
                ),
              ),
            ],
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_today),
                color: AppColors.accentColor,
                iconSize: 40.0,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentsPage(
                      token: widget.token,
                      ownerId: ownerId,
                    ),
                  ),
                ),
              ),
              const Text(
                'פגישות',
                style: TextStyle(
                  color: AppColors.textColor,
                  fontFamily: 'Alef',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Post {
  final String id;
  final String trainerId;
  final String trainerName;
  final String content;
  final DateTime createdAt;
  final List<String> media;
  final String profilePicture; // Add this field

  Post({
    required this.id,
    required this.trainerId,
    required this.trainerName,
    required this.content,
    required this.createdAt,
    required this.media,
    required this.profilePicture, // Add this field
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] as String,
      trainerId: (json['trainerId'] as Map<String, dynamic>)['_id'] as String,
      trainerName: json['trainerName'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      media: (json['media'] as List<dynamic>).cast<String>(),
      profilePicture: json['profilePicture'] as String, // Parse this field
    );
  }
}
