// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print, use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pinalprojectbark/design.dart';
import 'package:pinalprojectbark/pages/config.dart';
import '../owner/trainerProfileScreen.dart';
import 'package:intl/intl.dart' as intl;

class FeedPage extends StatefulWidget {
  final String token;
  final String userId;
  final String userName;
  final String role;
  final String profilePicture;

  const FeedPage({
    required this.token,
    required this.userId,
    required this.userName,
    required this.role,
    required this.profilePicture,
    super.key,
  });

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late Future<List<Post>> _posts;
  final TextEditingController _postController = TextEditingController();
  final List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    print('Profile picture URL: ${widget.profilePicture}');
    _posts = fetchPosts(widget.token);
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

  Future<void> createNewPost(String postContent, String userId, String userName,
      String profilePicture) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(createPost));
      request.headers['Authorization'] = 'Bearer ${widget.token}';

      request.fields['content'] = postContent;
      request.fields['trainerId'] = userId;
      request.fields['trainerName'] = userName;
      request.fields['profilePicture'] = profilePicture;

      for (File image in _selectedImages) {
        request.files.add(await http.MultipartFile.fromPath(
          'media',
          image.path,
        ));
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        print('Post created successfully');
        setState(() {
          _posts = fetchPosts(widget.token);
          _selectedImages.clear();
        });
      } else {
        var responseBody = await response.stream.bytesToString();
        print('Failed to create post: $responseBody');
        throw Exception('Failed to create post');
      }
    } catch (e) {
      print('Exception in createNewPost: $e');
      throw Exception('Failed to create post');
    }
  }

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    setState(() {
      _selectedImages.addAll(images.map((image) => File(image.path)));
    });
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'קיר פרסומים',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Inside the Column where you build the UI
            if (widget.role == 'trainer') ...[
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: widget.profilePicture != 'default_id'
                              ? NetworkImage(
                                  'http://192.168.70.1:3000/${widget.profilePicture}')
                              : const AssetImage('assets/images/logoMe.png')
                                  as ImageProvider,
                          radius: 25.0,
                          backgroundColor: AppColors.accentColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _postController,
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'כתוב כאן את הפוסט שלך',
                              hintStyle: TextStyle(
                                fontFamily: 'Alef',
                                color: AppColors.textColor,
                              ),
                              alignLabelWithHint: true,
                            ),
                            maxLines: null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_selectedImages.isNotEmpty)
                      Wrap(
                        spacing: 8.0,
                        children: _selectedImages.map((image) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.file(
                                  image,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.remove(image);
                                    });
                                  },
                                  child: const Icon(Icons.remove_circle,
                                      color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: pickImages,
                          icon: const Icon(Icons.photo_library,
                              color: AppColors.backgroundColor),
                          label: const Text(
                            'בחר תמונות',
                            style: TextStyle(
                              fontFamily: 'Alef',
                              color: AppColors.backgroundColor,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            final postContent = _postController.text;
                            if (postContent.isNotEmpty) {
                              createNewPost(postContent, widget.userId,
                                  widget.userName, widget.profilePicture);
                              _postController.clear();
                            }
                          },
                          icon: const Icon(Icons.send,
                              color: AppColors.backgroundColor),
                          label: const Text(
                            'פרסם',
                            style: TextStyle(
                              fontFamily: 'Alef',
                              color: AppColors.backgroundColor,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            Expanded(
              child: SingleChildScrollView(
                child: FutureBuilder<List<Post>>(
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: post
                                                  .profilePicture.isNotEmpty &&
                                              post.profilePicture !=
                                                  'default_id'
                                          ? NetworkImage(
                                              'http://192.168.70.1:3000/${post.profilePicture}')
                                          : const AssetImage(
                                                  'assets/images/logoMe.png')
                                              as ImageProvider,
                                      radius: 25.0,
                                      backgroundColor: AppColors.accentColor,
                                    ),
                                    const SizedBox(width: 10),
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
                                        Text(
                                          '$time, $date',
                                          style: const TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  post.content,
                                  style: const TextStyle(
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
                    } else if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return const Center(child: Text('No posts available.'));
                    } else {
                      return const Center(child: Text('No posts available.'));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatDate(DateTime dateTime) {
  return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}';
}

String formatTime(DateTime dateTime) {
  return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}

class Post {
  final String id;
  final String trainerId;
  final String trainerName;
  final String content;
  final DateTime createdAt;
  final List<String> media;
  final String profilePicture;

  Post({
    required this.id,
    required this.trainerId,
    required this.trainerName,
    required this.content,
    required this.createdAt,
    required this.media,
    required this.profilePicture,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] as String,
      trainerId: (json['trainerId'] as Map<String, dynamic>)['_id'] as String,
      trainerName: json['trainerName'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      media: (json['media'] as List<dynamic>).cast<String>(),
      profilePicture: json['profilePicture'] ?? 'default_id',
    );
  }
}
