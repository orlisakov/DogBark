// ignore_for_file: file_names, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pinalprojectbark/design.dart';
import 'package:pinalprojectbark/pages/config.dart';
import 'package:intl/intl.dart' as intl;

class AppointmentsPage extends StatefulWidget {
  final String token;
  final String ownerId;

  const AppointmentsPage({required this.token, required this.ownerId, Key? key})
      : super(key: key);

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  late Future<List<dynamic>> _appointments;

  @override
  void initState() {
    super.initState();
    _refreshAppointments();
  }

  void _refreshAppointments() {
    setState(() {
      _appointments = fetchAppointments();
    });
  }

  Future<List<dynamic>> fetchAppointments() async {
    final Uri uri = Uri.parse('$getAppointmentsByOwnerId/${widget.ownerId}');
    final response = await http.get(
      uri,
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse is Map<String, dynamic> &&
          jsonResponse['success'] is List) {
        final List<dynamic> appointments = jsonResponse['success'];

        // Filter appointments to only include those belonging to the current owner
        return appointments.where((appointment) {
          return appointment['ownerId'] == widget.ownerId;
        }).toList();
      } else {
        throw Exception('Unexpected JSON format: ${response.body}');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid token.');
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception(
          'Failed to load appointments: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  Future<String> _fetchTrainerName(String? tutorId) async {
    if (tutorId == null || tutorId.isEmpty) {
      return 'Unknown Trainer';
    }
    final response = await http.get(
      Uri.parse('$getTrainerById/$tutorId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['fullName'] ?? 'Unknown Trainer';
    } else if (response.statusCode == 404) {
      return 'Trainer not found';
    } else {
      print('Failed to fetch trainer name: ${response.statusCode}');
      return 'Unknown Trainer';
    }
  }

  Future<String> _fetchDogName(String? dogId) async {
    if (dogId == null || dogId.isEmpty) {
      return 'Unknown Dog';
    }
    final response = await http.get(
      Uri.parse('$getDogProfileById/$dogId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['DogName'] ?? 'Unknown Dog';
    } else if (response.statusCode == 404) {
      return 'Dog not found';
    } else {
      print('Failed to fetch dog name: ${response.statusCode}');
      return 'Unknown Dog';
    }
  }

  Future<void> _cancelAppointment(
      String tutorId, String day, String startTime) async {
    try {
      final Uri uri = Uri.parse('$cancelAppointment/$tutorId');
      final requestBody = {
        'day': day,
        'startTime': startTime,
      };

      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json"
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('הפגישה בוטלה בהצלחה')),
        );

        // Refresh the appointments list after a short delay to ensure server updates
        await Future.delayed(const Duration(milliseconds: 500));
        _refreshAppointments();
      } else {
        // Decode error message from server response
        final errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['message'] ?? 'ביטול הפגישה נכשל';

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (error) {
      // Handle any other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('שגיאה פנימית: $error')),
      );
    }
  }

  String formatDate(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);
    return intl.DateFormat('yyyy-MM-dd').format(dateTime);
  }

  String formatTime(String timeStr) {
    return timeStr;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text(
            'הפגישות שלי',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Rubik',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: _appointments,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final appointment = snapshot.data![index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row for date and time
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: AppColors.accentColor),
                                const SizedBox(width: 8.0),
                                Text(
                                  formatDate(appointment['day']),
                                  style: const TextStyle(
                                    fontFamily: 'Alef',
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                const SizedBox(
                                    width: 24.0), // Space between date and time
                                const Icon(Icons.access_time,
                                    color: AppColors.accentColor),
                                const SizedBox(width: 8.0),
                                Text(
                                  formatTime(appointment['startTime']),
                                  style: const TextStyle(
                                    fontFamily: 'Alef',
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            // Row for trainer name and dog name
                            Row(
                              children: [
                                FutureBuilder<String>(
                                  future:
                                      _fetchTrainerName(appointment['tutorId']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return const Text('Error');
                                    } else {
                                      return Row(
                                        children: [
                                          const Icon(Icons.person,
                                              color: AppColors.accentColor),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            snapshot.data ?? 'Unknown Trainer',
                                            style: const TextStyle(
                                              fontFamily: 'Alef',
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textColor,
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(
                                    width:
                                        24.0), // Space between trainer and dog name
                                FutureBuilder<String>(
                                  future: _fetchDogName(appointment['dogId']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return const Text('Error');
                                    } else {
                                      return Row(
                                        children: [
                                          const Icon(Icons.pets,
                                              color: AppColors.accentColor),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            snapshot.data ?? 'Unknown Dog',
                                            style: const TextStyle(
                                              fontFamily: 'Alef',
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textColor,
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: AppColors.secondaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  textStyle: const TextStyle(
                                    fontFamily: 'Rubik',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor:
                                          AppColors.backgroundColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: const Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'ביטול פגישה',
                                          style: TextStyle(
                                            fontFamily: 'Rubik',
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                      ),
                                      content: const Text(
                                        '?האם אתה בטוח שברצונך לבטל את הפגישה',
                                        style: TextStyle(
                                          fontFamily: 'Alef',
                                          color: AppColors.textColor,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text(
                                            'לא',
                                            style: TextStyle(
                                              fontFamily: 'Rubik',
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                        ),
                                        TextButton(
                                          child: const Text(
                                            'כן',
                                            style: TextStyle(
                                              fontFamily: 'Rubik',
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await _cancelAppointment(
                                      appointment['tutorId'],
                                      appointment['day'],
                                      appointment['startTime'],
                                    );
                                  }
                                },
                                child: const Text(
                                  'ביטול',
                                  style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text(
                  'אין לך פגישות אילוף',
                  style: TextStyle(
                    fontFamily: 'Alef',
                    color: AppColors.textColor,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
