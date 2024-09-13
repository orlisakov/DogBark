// ignore_for_file: avoid_print, library_private_types_in_public_api
import 'dart:convert';
import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pinalprojectbark/design.dart';
import 'package:pinalprojectbark/pages/config.dart';
import 'package:video_player/video_player.dart';

class ChatPage extends StatefulWidget {
  final String token;
  final String chatId;
  final String senderId;
  final String senderType;

  const ChatPage({
    Key? key,
    required this.token,
    required this.chatId,
    required this.senderId,
    required this.senderType,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Future<List<dynamic>> _messages;
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _messages = fetchMessages();
  }

  Future<List<dynamic>> fetchMessages() async {
    final Uri uri = Uri.parse('$getMessagesByChatId/${widget.chatId}');
    final response = await http
        .get(uri, headers: {"Authorization": "Bearer ${widget.token}"});

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse is Map<String, dynamic> &&
          jsonResponse['success'] is List) {
        return jsonResponse['success'];
      } else {
        throw Exception('Unexpected JSON format');
      }
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<void> sendMessage(String messageType, String messageContent) async {
    final Uri uri = Uri.parse(createMessage);
    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer ${widget.token}",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        'chatId': widget.chatId,
        'senderId': widget.senderId,
        'senderType': widget.senderType,
        'messageType': messageType,
        'messageContent': messageContent,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _messages = fetchMessages();
      });
      _messageController.clear();
    } else {
      throw Exception('Failed to send message');
    }
  }

  Future<void> sendImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String imageUrl = await _uploadMedia(pickedFile);
      sendMessage('image', imageUrl);
    }
  }

  Future<void> sendVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      String videoUrl = await _uploadMedia(pickedFile);
      sendMessage('video', videoUrl);
    }
  }

  Future<String> _uploadMedia(XFile file) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(uploadMediaUrl));

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'media',
          bytes,
          filename: file.name,
        ));
      } else {
        request.files
            .add(await http.MultipartFile.fromPath('media', file.path));
      }

      request.headers['Authorization'] = 'Bearer ${widget.token}';
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);

        if (jsonResponse['status'] == true &&
            jsonResponse['mediaUrl'] != null) {
          return jsonResponse['mediaUrl'];
        } else {
          print('Error in server response: ${jsonResponse['error']}');
          throw Exception('Failed to upload media');
        }
      } else {
        var errorResponse = await response.stream.bytesToString();
        print('Upload failed with status: ${response.statusCode}');
        print('Server response: $errorResponse');
        throw Exception('Failed to upload media');
      }
    } catch (e) {
      print('Error during media upload: $e');
      throw Exception('Failed to upload media');
    }
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    bool isMe = message['senderId'] == widget.senderId;

    String senderName;
    if (isMe) {
      senderName = 'את/ה';
    } else {
      senderName = widget.senderType == 'Trainer' ? 'מאלף' : 'בעלים';
    }

    // פורמט תאריך ושעה
    String formattedDateTime = _formatDateTime(message['createdAt']);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: isMe
            ? const EdgeInsets.only(top: 10, bottom: 10, left: 80)
            : const EdgeInsets.only(top: 10, bottom: 10, right: 80),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isMe ? AppColors.secondaryColor : AppColors.primaryColor,
          borderRadius: isMe
              ? const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30))
              : const BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              senderName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            message['messageType'] == 'text'
                ? Text(
                    message['messageContent'],
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.right,
                  )
                : _buildMediaWidget(message), // שימוש בפונקציה להצגת מדיה
            const SizedBox(height: 5),
            Text(
              formattedDateTime,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

// פונקציה פשוטה לפורמט תאריך ושעה (ללא שימוש ב-intl)
  String _formatDateTime(String dateTime) {
    DateTime parsedDateTime = DateTime.parse(dateTime);
    return '${parsedDateTime.day.toString().padLeft(2, '0')}.${parsedDateTime.month.toString().padLeft(2, '0')}.${parsedDateTime.year} ${parsedDateTime.hour.toString().padLeft(2, '0')}:${parsedDateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMediaWidget(Map<String, dynamic> message) {
    if (message['messageType'] == 'image') {
      final imageUrl = message['messageContent'];

      if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
        // Network image
        return Image.network(
          imageUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder:
              (BuildContext context, Object exception, StackTrace? stackTrace) {
            print('Failed to load image: $exception');
            return const Text('Failed to load image');
          },
        );
      } else {
        // Local file image
        return Image.file(
          File(imageUrl.replaceFirst('file:///', '')),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder:
              (BuildContext context, Object exception, StackTrace? stackTrace) {
            print('Failed to load image: $exception');
            return const Text('Failed to load image');
          },
        );
      }
    } else if (message['messageType'] == 'video') {
      final videoUrl = message['messageContent'];

      if (videoUrl.startsWith('http') || videoUrl.startsWith('https')) {
        // Network video
        return SizedBox(
          width: 150,
          height: 150,
          child: VideoPlayerWidget(
            url: videoUrl,
          ),
        );
      } else {
        // Local file video
        return SizedBox(
          width: 150,
          height: 150,
          child: VideoPlayerWidget(
            file: File(videoUrl.replaceFirst('file:///', '')),
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'צ\'אט אישי',
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.right,
          ),
          centerTitle: true,
          backgroundColor: AppColors.primaryColor,
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _messages,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('אין הודעות זמינות.'));
                    } else {
                      return ListView.builder(
                        reverse: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var message =
                              snapshot.data![snapshot.data!.length - 1 - index];
                          return _buildMessage(message);
                        },
                      );
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo),
                      color: AppColors.accentColor,
                      onPressed: sendImage,
                    ),
                    IconButton(
                      icon: const Icon(Icons.videocam),
                      color: AppColors.accentColor,
                      onPressed: sendVideo,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          labelText: 'הודעה',
                          labelStyle: const TextStyle(
                            fontFamily: 'Alef',
                            color: AppColors.textColor,
                          ),
                          fillColor: AppColors.backgroundColor,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: AppColors.secondaryColor,
                      onPressed: () {
                        if (_messageController.text.isNotEmpty) {
                          sendMessage('text', _messageController.text);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String? url;
  final File? file;

  const VideoPlayerWidget({
    Key? key,
    this.url,
    this.file,
  })  : assert(
            url != null || file != null, 'Either url or file must be provided'),
        super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    if (kIsWeb || !Platform.isAndroid && !Platform.isIOS) {
      // Handle non-supported platforms
      print('Video playback is not supported on this platform.');
    } else {
      if (widget.url != null) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url!));
      } else if (widget.file != null) {
        _controller = VideoPlayerController.file(widget.file!);
      }

      if (_controller != null) {
        _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
          setState(() {
            _controller?.play();
          });
        }).catchError((error) {
          print('Error initializing video player: $error');
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _initializeVideoPlayerFuture == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'Video playback is not supported on this platform.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<void>(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller?.value.aspectRatio ?? 16 / 9,
            child: VideoPlayer(_controller!),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Failed to load video'),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
