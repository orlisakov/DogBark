// ignore_for_file: file_names, use_build_context_synchronously, avoid_print, library_private_types_in_public_api, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pinalprojectbark/design.dart';
import 'package:pinalprojectbark/pages/config.dart';
import 'package:video_player/video_player.dart';

class TrainerRecommendationsPage extends StatefulWidget {
  final String trainerId;
  final String token;

  const TrainerRecommendationsPage({
    Key? key,
    required this.trainerId,
    required this.token,
  }) : super(key: key);

  @override
  TrainerRecommendationsPageState createState() =>
      TrainerRecommendationsPageState();
}

class TrainerRecommendationsPageState
    extends State<TrainerRecommendationsPage> {
  List<Map<String, dynamic>> recommendations = [];

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    try {
      final url = '$getTrainerRecommendations/${widget.trainerId}';

      var response = await http.get(
        Uri.parse(url),
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
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.bold,
                            ),
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
                          spacing: 16.0,
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
                                borderRadius: BorderRadius.circular(
                                    8.0), // עגלת פינות התמונה
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'המלצות שלי',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryColor,
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRecommendationsList(),
                ],
              ),
            ),
          ),
        ),
      ),
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
          onPressed: () {},
        );
      }),
    );
  }
}
