// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pinalprojectbark/pages/config.dart';
import 'package:pinalprojectbark/design.dart';

class DogTasksPage extends StatefulWidget {
  final String token;
  final String dogId;

  const DogTasksPage({
    Key? key,
    required this.token,
    required this.dogId,
  }) : super(key: key);

  @override
  State<DogTasksPage> createState() => _DogTasksPageState();
}

class _DogTasksPageState extends State<DogTasksPage> {
  late Future<List<dynamic>> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = fetchTasks();
  }

  Future<List<dynamic>> fetchTasks() async {
    final Uri uri = Uri.parse('$getTasksByDogId/${widget.dogId}');
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
      throw Exception('Failed to load tasks');
    }
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    final Uri uri = Uri.parse(updateTaskDogStatus);
    final response = await http.put(
      uri,
      headers: {
        "Authorization": "Bearer ${widget.token}",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        'taskId': taskId,
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _tasks = fetchTasks();
      });
    } else {
      throw Exception('Failed to update task status');
    }
  }

  String formatDate(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "משימות אילוף ביתיות",
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: FutureBuilder<List<dynamic>>(
            future: _tasks,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No tasks found.'));
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var task = snapshot.data![index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task['description'],
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'סטטוס: ${task['status']}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: task['status'] == 'בוצע'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                DropdownButton<String>(
                                  value: task['status'] == 'בתהליך'
                                      ? 'בתהליך'
                                      : 'בוצע',
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      String status = newValue == 'בתהליך'
                                          ? 'בתהליך'
                                          : 'בוצע';
                                      updateTaskStatus(task['_id'], status);
                                    }
                                  },
                                  items: <String>['בתהליך', 'בוצע']
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'תאריך יצירה: ${formatDate(task['createdDate'])}',
                              style: const TextStyle(
                                fontSize: 12.0,
                                color: AppColors.textColor,
                              ),
                            ),
                            Text(
                              'תאריך סיום: ${formatDate(task['dueDate'])}',
                              style: const TextStyle(
                                fontSize: 12.0,
                                color: AppColors.textColor,
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
      ),
    );
  }
}
