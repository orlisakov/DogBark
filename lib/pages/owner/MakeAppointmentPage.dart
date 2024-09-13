// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously, sort_child_properties_last, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pinalprojectbark/design.dart';
import 'package:pinalprojectbark/pages/config.dart';
import 'package:pinalprojectbark/pages/owner/homePageOwner.dart';

class MakeAppointmentPage extends StatefulWidget {
  final String token;
  final String trainerId;
  final String dogId;

  const MakeAppointmentPage({
    Key? key,
    required this.token,
    required this.trainerId,
    required this.dogId,
  }) : super(key: key);

  @override
  _MakeAppointmentPageState createState() => _MakeAppointmentPageState();
}

class _MakeAppointmentPageState extends State<MakeAppointmentPage> {
  Map<String, List<Map<String, dynamic>>> _schedule = {};
  bool _isLoading = true;
  String _selectedDay = '';
  String? _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    _fetchTrainerSchedule();
  }

  Future<void> _fetchTrainerSchedule() async {
    final Uri apiUri = Uri.parse('$getScheduleByTutorId/${widget.trainerId}');
    final response = await http.get(
      apiUri,
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        _schedule = {};
        for (var entry in jsonResponse['schedule']) {
          String day = entry['day'] as String;
          List<Map<String, dynamic>> times = (entry['times'] as List).isEmpty
              ? []
              : (entry['times'] as List).map((time) {
                  return {
                    'startTime': time['startTime'],
                    'endTime': time['endTime'],
                    'available': time['available'],
                  };
                }).toList();
          _schedule[day] = times;
        }
        if (_schedule.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No available schedule found for the trainer.')),
          );
        }
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load trainer schedule.')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makeAppointment() async {
    if (_selectedDay.isEmpty || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a day and time slot.')),
      );
      return;
    }

    final decodedToken = JwtDecoder.decode(widget.token);
    final String ownerId = decodedToken['_id'] ?? '';
    final String dogId = widget.dogId;

    final Uri apiUri = Uri.parse(makeAppointment);
    final response = await http.post(
      apiUri,
      headers: {
        "Authorization": "Bearer ${widget.token}",
        "Content-Type": "application/json",
      },
      body: json.encode({
        'trainerId': widget.trainerId,
        'day': _selectedDay,
        'startTime': _selectedTimeSlot,
        'ownerId': ownerId,
        'dogId': dogId,
      }),
    );

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: AppColors.backgroundColor,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '!הפגישה נקבעה',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.textColor,
                    fontFamily: 'Rubik',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'הפגישה נקבעה ל$_selectedDay',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textColor,
                        fontFamily: 'Alef',
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.calendar_today,
                        color: AppColors.primaryColor),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'בשעה $_selectedTimeSlot',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textColor,
                        fontFamily: 'Alef',
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.access_time,
                        color: AppColors.primaryColor),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '!נתראה',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textColor,
                    fontFamily: 'Alef',
                  ),
                ),
                const Text(
                  '😊',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: AppColors.primaryColor,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: const Text(
                    'אישור',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the AlertDialog
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) =>
                            HomePageOwner(token: widget.token),
                      ),
                      (Route<dynamic> route) =>
                          false, // Remove all previous routes
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to make an appointment!!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.brown,
          title: const Text(
            'קבע פגישת אילוף',
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildAppointmentForm(),
      ),
    );
  }

  Widget _buildAppointmentForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 50.0),
          if (_schedule.isNotEmpty)
            FractionallySizedBox(
              widthFactor: 0.8,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'בחר יום',
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  filled: true,
                  fillColor: Colors.brown[50],
                ),
                items: _schedule.keys.map((day) {
                  return DropdownMenuItem(
                    value: day,
                    child: Center(child: Text(day)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDay = value!;
                    _selectedTimeSlot = null;
                  });
                },
                value: _selectedDay.isEmpty ? null : _selectedDay,
              ),
            ),
          const SizedBox(height: 20.0),
          if (_selectedDay.isNotEmpty && _schedule[_selectedDay]!.isNotEmpty)
            FractionallySizedBox(
              widthFactor: 0.8,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'בחר שעה',
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  filled: true,
                  fillColor: Colors.brown[50],
                ),
                items: _schedule[_selectedDay]!
                    .where((slot) => slot['available'] == true)
                    .map((slot) {
                  return DropdownMenuItem<String>(
                    value: slot['startTime'],
                    child: Center(
                        child:
                            Text('${slot['startTime']} - ${slot['endTime']}')),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTimeSlot = value;
                  });
                },
                value: _selectedTimeSlot,
              ),
            ),
          const SizedBox(height: 30.0),
          if (_schedule.isNotEmpty)
            Center(
              child: ElevatedButton(
                onPressed: _makeAppointment,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 30.0),
                  backgroundColor: Colors.brown,
                ),
                child: const Text(
                  'קבע פגישה',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          if (_schedule.isEmpty)
            const Center(
              child: Text(
                'אין תורים זמינים כעת, נסה מאוחר יותר',
                style: TextStyle(
                  fontFamily: 'Alef',
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
