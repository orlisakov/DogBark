// ignore_for_file: file_names, use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pinalprojectbark/design.dart';
import 'package:pinalprojectbark/pages/config.dart';
import 'package:pinalprojectbark/pages/owner/DogTasksPage.dart';

import 'package:pinalprojectbark/pages/chat_page.dart';
import 'package:pinalprojectbark/pages/owner/MakeAppointmentPage.dart';
import 'package:pinalprojectbark/pages/owner/trainerProfileScreen.dart';

class MyTrainingProcesses extends StatefulWidget {
  final String token;
  const MyTrainingProcesses({required this.token, super.key});

  @override
  State<MyTrainingProcesses> createState() => _MyTrainingProcessesState();
}

class _MyTrainingProcessesState extends State<MyTrainingProcesses> {
  late Future<List<dynamic>> _trainingProcesses;

  @override
  void initState() {
    super.initState();
    _trainingProcesses = fetchTrainingProcesses();
  }

  Future<List<dynamic>> fetchTrainingProcesses() async {
    final decodedToken = JwtDecoder.decode(widget.token);
    final String ownerId = decodedToken['_id'] ?? '';
    final Uri apiUri = Uri.parse('$getOwnerApprovedProcesses/$ownerId');

    final response = await http.get(
      apiUri,
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse is Map<String, dynamic> &&
          jsonResponse.containsKey('success') &&
          jsonResponse['success'] is List) {
        return jsonResponse['success'];
      } else {
        throw Exception(
            'Invalid JSON structure: Expected object with "success" key containing a list');
      }
    } else {
      throw Exception('Failed to load training processes');
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
      //print('Response Body: $responseBody'); // Log the raw response body

      final jsonResponse = json.decode(responseBody);
      if (jsonResponse is List && jsonResponse.isNotEmpty) {
        final trainerProfile = jsonResponse.first;
        if (trainerProfile is Map<String, dynamic>) {
          /*print(
              'Trainer Profile Data: $trainerProfile');*/
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
          title: const Text(
            'תהליכי האילוף שלי',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontFamily: 'Rubik',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: _trainingProcesses,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final process = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: AppColors.backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      child: InkWell(
                        onTap: () async {
                          try {
                            final trainerProfile =
                                await fetchTrainerProfile(process['trainerId']);
                            final bool? result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TrainerProfileScreen(
                                  trainerData: trainerProfile,
                                  token: widget.token,
                                ),
                              ),
                            );
                            if (result == true) {
                              setState(() {
                                _trainingProcesses = fetchTrainingProcesses();
                              });
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.pets,
                                  color: AppColors.accentColor),
                              title: Text(
                                process['dogName'].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                  fontFamily: 'Rubik',
                                ),
                              ),
                              subtitle: Text(
                                'מאמן: ${process['trainerName']}',
                                style: const TextStyle(
                                  color: AppColors.textColor,
                                  fontFamily: 'Alef',
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (process['_id'] != null &&
                                        process['OwnerId'] != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                            token: widget.token,
                                            chatId: process['_id'],
                                            senderId: process['OwnerId'],
                                            senderType: 'Owner',
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('נתונים חסרים.')),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.chat,
                                      color: AppColors.backgroundColor),
                                  label: const Text(
                                    'צאט',
                                    style: TextStyle(
                                      fontFamily: 'Alef',
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondaryColor,
                                    foregroundColor: AppColors.backgroundColor,
                                    fixedSize: const Size.fromHeight(35),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DogTasksPage(
                                          token: widget.token,
                                          dogId: process['dogId'],
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.home,
                                      color: AppColors.backgroundColor),
                                  label: const Text(
                                    'אימון ביתי',
                                    style: TextStyle(
                                      fontFamily: 'Alef',
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentColor,
                                    foregroundColor: AppColors.backgroundColor,
                                    fixedSize: const Size.fromHeight(35),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5.0),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MakeAppointmentPage(
                                        token: widget.token,
                                        trainerId: process['trainerId'],
                                        dogId: process['dogId'],
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.calendar_today,
                                    color: AppColors.backgroundColor),
                                label: const Text(
                                  'קביעת פגישה',
                                  style: TextStyle(
                                    fontFamily: 'Alef',
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: AppColors.backgroundColor,
                                  fixedSize: const Size.fromHeight(35),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
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
                  'אין נתונים להצגה',
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontFamily: 'Alef',
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
