// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:pinalprojectbark/design.dart'; // ייבוא AppColors
import 'package:pinalprojectbark/pages/config.dart';

class MonthlySchedulePage extends StatefulWidget {
  final String token;
  final String tutorId;

  const MonthlySchedulePage({
    Key? key,
    required this.token,
    required this.tutorId,
  }) : super(key: key);

  @override
  _MonthlySchedulePageState createState() => _MonthlySchedulePageState();
}

class _MonthlySchedulePageState extends State<MonthlySchedulePage> {
  Map<String, List<Map<String, dynamic>>> _workingHours = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocaleAndFetchData();
  }

  Future<void> _initializeLocaleAndFetchData() async {
    await initializeDateFormatting('he_IL', null);
    await _fetchWorkingHours();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchWorkingHours() async {
    try {
      final response = await http.get(
        Uri.parse('$getScheduleByTutorId/${widget.tutorId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      print('Request URL: $getScheduleByTutorId/${widget.tutorId}');
      print('Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Fetched Data: $data');

        final workingHours = <String, List<Map<String, dynamic>>>{};
        for (var entry in data['schedule']) {
          String day = entry['day'] as String;
          print('Processing Day: $day');

          List<Map<String, dynamic>> times = (entry['times'] as List).isEmpty
              ? []
              : await Future.wait((entry['times'] as List).map((time) async {
                  print('Processing Time Slot: $time');

                  final ownerName = await _fetchOwnerName(time['ownerId']);
                  final dogName = await _fetchDogName(time['dogId']);
                  print('Owner Name: $ownerName, Dog Name: $dogName');

                  // Ensure available is not null, default to false
                  final bool isAvailable = time['available'] != null
                      ? time['available'] as bool
                      : false;

                  return {
                    'startTime': TimeOfDay(
                      hour: int.parse(time['startTime'].split(":")[0]),
                      minute: int.parse(time['startTime'].split(":")[1]),
                    ),
                    'endTime': TimeOfDay(
                      hour: int.parse(time['endTime'].split(":")[0]),
                      minute: int.parse(time['endTime'].split(":")[1]),
                    ),
                    'ownerName': ownerName,
                    'dogName': dogName,
                    'available': isAvailable,
                  };
                }).toList());

          workingHours[day] = times;
          //print('Working Hours for $day: $times');
        }

        setState(() {
          _workingHours = workingHours;
        });
        //print('Final Working Hours: $_workingHours');
      } else if (response.statusCode == 500) {
        print('Server-side error occurred.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
            'Server error occurred. Please try again later.',
            style: TextStyle(fontFamily: 'Rubik'),
          )),
        );
      } else {
        print('Failed to load schedule: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'Failed to load schedule: ${response.statusCode}',
            style: const TextStyle(fontFamily: 'Rubik'),
          )),
        );
      }
    } catch (error) {
      print('Error fetching schedule: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to load schedule.',
            style: TextStyle(fontFamily: 'Rubik'),
          ),
        ),
      );
    }
  }

  Future<String> _fetchOwnerName(String? ownerId) async {
    if (ownerId == null || ownerId.isEmpty) {
      return 'Unknown Owner';
    }
    final response = await http.get(
      Uri.parse('$getOwnerById/$ownerId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['userName'] ?? 'Unknown Owner';
    } else {
      print('Failed to fetch owner name: ${response.statusCode}');
      return 'Unknown Owner';
    }
  }

  Future<String> _fetchDogName(String? dogId) async {
    if (dogId == null || dogId.isEmpty) {
      return 'Unknown Dog';
    }
    final dogUrl = '$getDogProfileById/$dogId';
    final response = await http.get(
      Uri.parse(dogUrl),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['DogName'] ?? 'Unknown Dog';
    } else {
      print('Failed to fetch dog name: ${response.statusCode}');
      return 'Unknown Dog';
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
            'לוח זמנים שבועי',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Rubik',
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _workingHours.isEmpty
                ? const Center(
                    child: Text(
                    'לא הגדרת לוח זמנים שבועי',
                    style: TextStyle(
                      fontFamily: 'Alef',
                      color: AppColors.textColor,
                    ),
                  ))
                : _buildScheduleTable(),
      ),
    );
  }

  Widget _buildScheduleTable() {
    return ListView.builder(
      itemCount: _workingHours.keys.length,
      itemBuilder: (context, index) {
        String day = _workingHours.keys.elementAt(index);
        List<Map<String, dynamic>> times = _workingHours[day] ?? [];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: AppColors.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Rubik',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ..._buildTimeSlots(times),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildTimeSlots(List<Map<String, dynamic>> times) {
    return times.map((time) {
      final bool isAvailable = time['ownerName'] == 'Unknown Owner' &&
          time['dogName'] == 'Unknown Dog';
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isAvailable ? 'פנוי' : 'תפוס',
              style: const TextStyle(
                color: AppColors.accentColor,
                fontFamily: 'Alef',
                fontSize: 16,
              ),
            ),
            Text(
              '${time['startTime'].format(context)} - ${time['endTime'].format(context)}',
              style: const TextStyle(
                color: AppColors.textColor,
                fontFamily: 'Alef',
                fontSize: 16,
              ),
            ),
            if (!isAvailable)
              Text(
                '${time['ownerName']} (${time['dogName']})',
                style: const TextStyle(
                  color: AppColors.textColor,
                  fontFamily: 'Alef',
                  fontSize: 16,
                ),
              ),
          ],
        ),
      );
    }).toList();
  }
}
