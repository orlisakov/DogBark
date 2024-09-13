// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:pinalprojectbark/design.dart';
import 'package:pinalprojectbark/pages/config.dart';

class TrainerTasksPage extends StatefulWidget {
  final String token;
  final String dogId;
  final String OwnerId;
  final String ownerName;
  final String trainerId;
  final String trainerName;
  final String dogName;

  const TrainerTasksPage({
    Key? key,
    required this.token,
    required this.dogId,
    required this.OwnerId,
    required this.ownerName,
    required this.trainerId,
    required this.trainerName,
    required this.dogName,
  }) : super(key: key);

  @override
  State<TrainerTasksPage> createState() => _TrainerTasksPageState();
}

class _TrainerTasksPageState extends State<TrainerTasksPage> {
  late Future<List<dynamic>> _tasks;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tasks = fetchTasks();
  }

  Future<List<dynamic>> fetchTasks() async {
    final Uri uri = Uri.parse('$getTasksByDogId/${widget.dogId}');
    final response =
        await http.get(uri, headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse is Map<String, dynamic> &&
          jsonResponse['success'] is List) {
        return jsonResponse['success'];
      } else {
        throw Exception('Unexpected JSON format');
      }
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<void> createTask(
    String OwnerId,
    String ownerName,
    String trainerId,
    String trainerName,
    String dogId,
    String dogName,
    String description,
    String dueDate,
  ) async {
    final Uri uri = Uri.parse(createNewTask);
    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer ${widget.token}",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        'OwnerId': OwnerId,
        'userName': ownerName,
        'trainerId': trainerId,
        'trainerName': trainerName,
        'dogId': dogId,
        'dogName': dogName,
        'description': description,
        'status': 'בתהליך',
        'dueDate': dueDate,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _tasks = fetchTasks();
      });
      _descriptionController.clear();
      _dueDateController.clear();
    } else {
      throw Exception('Failed to create task');
    }
  }

  String formatDate(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);
    return intl.DateFormat('yyyy-MM-dd').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "משימות לאילוף",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Rubik',
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _tasks,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('לא נמצאו משימות.'));
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final task = snapshot.data![index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'תיאור: ${task['description']}',
                                    style: const TextStyle(
                                      fontFamily: 'Alef',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'סטטוס: ${task['status']}',
                                    style: const TextStyle(
                                      fontFamily: 'Alef',
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'תאריך יצירה: ${formatDate(task['createdDate'])}',
                                    style: const TextStyle(
                                      fontFamily: 'Alef',
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'תאריך סיום: ${formatDate(task['dueDate'])}',
                                    style: const TextStyle(
                                      fontFamily: 'Alef',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'תיאור המשימה',
                            labelStyle: const TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            filled: true,
                            fillColor: const Color.fromARGB(253, 255, 248, 248),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextField(
                          controller: _dueDateController,
                          decoration: InputDecoration(
                            labelText: 'תאריך סיום (YYYY-MM-DD)',
                            labelStyle: const TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            filled: true,
                            fillColor: const Color.fromARGB(253, 255, 248, 248),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_descriptionController.text.isNotEmpty &&
                                _dueDateController.text.isNotEmpty) {
                              final intl.DateFormat formatter =
                                  intl.DateFormat('yyyy-MM-dd');
                              final String formattedDueDate = formatter.format(
                                  DateTime.parse(_dueDateController.text));
                              createTask(
                                widget.OwnerId,
                                widget.ownerName,
                                widget.trainerId,
                                widget.trainerName,
                                widget.dogId,
                                widget.dogName,
                                _descriptionController.text,
                                formattedDueDate,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            backgroundColor: AppColors.secondaryColor,
                          ),
                          icon: const Icon(Icons.add_task,
                              color: Colors.black), // Use an appropriate icon
                          label: const Text('הוסף משימה חדשה',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 15)),
                        ),
                      ),
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
