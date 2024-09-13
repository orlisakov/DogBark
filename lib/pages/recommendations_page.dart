// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print, library_private_types_in_public_api
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:pinalprojectbark/design.dart';
import 'package:video_player/video_player.dart';
import 'package:pinalprojectbark/pages/config.dart';

class RecommendationsPage extends StatefulWidget {
  final String trainerId;
  final String ownerId;
  final String ownerName;
  final String token;

  const RecommendationsPage({
    Key? key,
    required this.trainerId,
    required this.ownerId,
    required this.ownerName,
    required this.token,
  }) : super(key: key);

  @override
  RecommendationsPageState createState() => RecommendationsPageState();
}

class RecommendationsPageState extends State<RecommendationsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ownerNameController;
  int rating = 1;
  String description = '';
  List<Map<String, dynamic>> mediaFiles = [];
  List<Map<String, dynamic>> recommendations = [];
  final picker = ImagePicker();
  String _mediaType = 'image';

  @override
  void initState() {
    super.initState();
    _ownerNameController = TextEditingController(text: widget.ownerName);
    _fetchRecommendations();
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchRecommendations() async {
    try {
      var response = await http.get(
        Uri.parse('$getRecommendations/${widget.trainerId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          recommendations =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to load recommendations.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("An error occurred.")));
    }
  }

  Future<void> _submitRecommendation() async {
    bool workingTogether =
        await checkWorkingTogether(widget.trainerId, widget.ownerId);

    if (!workingTogether) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "You are not authorized to leave a recommendation for this trainer.")));
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var request =
          http.MultipartRequest('POST', Uri.parse(createRecommendation));
      request.fields['ownerId'] = widget.ownerId;
      request.fields['trainerId'] = widget.trainerId;
      request.fields['ownerName'] = widget.ownerName;
      request.fields['rating'] = rating.toString();
      request.fields['description'] = description;

      for (var media in mediaFiles) {
        if (kIsWeb) {
          if (media['type'] == 'image') {
            request.files.add(http.MultipartFile.fromBytes(
                'media', media['data'],
                filename: 'web_image.png'));
          } else if (media['type'] == 'video') {
            request.files.add(http.MultipartFile.fromBytes(
                'media', media['data'],
                filename: 'web_video.mp4'));
          }
        } else {
          if (media['type'] == 'image') {
            request.files
                .add(await http.MultipartFile.fromPath('media', media['path']));
          } else if (media['type'] == 'video') {
            request.files
                .add(await http.MultipartFile.fromPath('media', media['path']));
          }
        }
      }

      request.headers['Authorization'] = 'Bearer ${widget.token}';
      var response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Recommendation submitted successfully!")));
        _fetchRecommendations();
        _resetForm(); // Reset form fields after successful submission
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to submit recommendation.")));
      }
    }
  }

  Future<bool> checkWorkingTogether(String trainerId, String ownerId) async {
    try {
      final response = await http.get(
        Uri.parse('$checkIfWorkingTogetherTrainerAndOwner/$ownerId/$trainerId'),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['isWorkingTogether'] ?? false;
      } else {
        throw Exception('Failed to check if working together');
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> _pickMedia() async {
    try {
      final pickedFile = _mediaType == 'image'
          ? await picker.pickImage(source: ImageSource.gallery)
          : await picker.pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            mediaFiles.add({
              'type': _mediaType,
              'data': bytes,
              'path': pickedFile.path,
            });
          });
        } else {
          setState(() {
            mediaFiles.add({
              'type': _mediaType,
              'file': File(pickedFile.path),
              'path': pickedFile.path,
            });
          });
        }
        print('File added: ${pickedFile.path}');
      } else {
        print('No file selected');
      }
    } catch (e) {
      print('Error picking media: $e');
    }
  }

  void _resetForm() {
    setState(() {
      rating = 1;
      description = '';
      mediaFiles.clear();
    });
    _formKey.currentState!.reset();
  }

  Widget _buildMediaWidget(dynamic media) {
    if (media['type'] == 'image') {
      return kIsWeb
          ? Image.memory(
              media['data'],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                print('Failed to load image: $exception');
                return const Text('Failed to load image');
              },
            )
          : Image.file(
              media['file'],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                print('Failed to load image: $exception');
                return const Text('Failed to load image');
              },
            );
    } else if (media['type'] == 'video') {
      return SizedBox(
        width: 100,
        height: 100,
        child: VideoPlayerWidget(
          file: media['file'],
          url: media['path'],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildRecommendationsList() {
    return recommendations.isEmpty
        ? const Center(child: Text('אין המלצות זמינות'))
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: AppColors.backgroundColor,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              recommendation['ownerName'],
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontFamily: 'Rubik',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          const Text(
                            'דרג:',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          HeartRating(
                            rating: recommendation['rating'],
                            onRatingChanged: (rating) {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        recommendation['description'],
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'Alef',
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      if (recommendation['media'] != null &&
                          recommendation['media'] is List &&
                          (recommendation['media'] as List).isNotEmpty)
                        Wrap(
                          spacing: 8.0,
                          children:
                              (recommendation['media'] as List).map((media) {
                            final imageUrl = 'http://192.168.70.1:3000/$media';

                            if (imageUrl.endsWith('.mp4')) {
                              return SizedBox(
                                width: 100,
                                height: 100,
                                child: VideoPlayerWidget(
                                  url: imageUrl,
                                ),
                              );
                            } else {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  imageUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (BuildContext context,
                                      Object exception,
                                      StackTrace? stackTrace) {
                                    print('Failed to load image: $exception');
                                    return const Text('Failed to load image');
                                  },
                                ),
                              );
                            }
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'דף המלצות',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryColor,
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'המלצות קיימות',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Rubik',
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _buildRecommendationsList(),
                  const Divider(color: AppColors.accentColor),
                  const Text(
                    'הוסף המלצה חדשה',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Rubik',
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Center(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      color: AppColors.backgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'שם:',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Alef',
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(
                                      _ownerNameController.text,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: 'Alef',
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  const Text(
                                    'דרג:',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontFamily: 'Alef',
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                  HeartRating(
                                    rating: rating,
                                    onRatingChanged: (newRating) {
                                      setState(() {
                                        rating = newRating;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'תיאור',
                                  labelStyle: const TextStyle(
                                    fontFamily: 'Alef',
                                    color: AppColors.textColor,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColors.accentColor),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                maxLines: 4,
                                onSaved: (value) => description = value!,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'תיאור הוא שדה חובה';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _mediaType = 'image';
                                      });
                                      _pickMedia();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: AppColors.primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: const Text(
                                      'הוסף תמונה',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontFamily: 'Alef',
                                        color: AppColors.backgroundColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _mediaType = 'video';
                                      });
                                      _pickMedia();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: AppColors.primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: const Text(
                                      'הוסף וידאו',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontFamily: 'Alef',
                                        color: AppColors.backgroundColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Wrap(
                                spacing: 8.0,
                                children: mediaFiles.map((file) {
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        child: _buildMediaWidget(file),
                                      ),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              mediaFiles.remove(file);
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
                              const SizedBox(height: 16.0),
                              Center(
                                child: ElevatedButton(
                                  onPressed: _submitRecommendation,
                                  style: ElevatedButton.styleFrom(
                                    primary: AppColors.secondaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  child: const Text(
                                    'שליחת ההמלצה',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontFamily: 'Alef',
                                      color: AppColors.backgroundColor,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HeartRating extends StatelessWidget {
  final int rating;
  final void Function(int) onRatingChanged;

  const HeartRating({
    Key? key,
    required this.rating,
    required this.onRatingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.favorite : Icons.favorite_border,
            color: index < rating ? AppColors.accentColor : Colors.grey,
          ),
          onPressed: () {
            onRatingChanged(index + 1);
          },
        );
      }),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String? url;
  final File? file;

  const VideoPlayerWidget({Key? key, this.url, this.file}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.url != null) {
      _controller = VideoPlayerController.network(widget.url!)
        ..initialize().then((_) {
          setState(() {});
          _controller.play();
        });
    } else if (widget.file != null) {
      _controller = VideoPlayerController.file(widget.file!)
        ..initialize().then((_) {
          setState(() {});
          _controller.play();
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
