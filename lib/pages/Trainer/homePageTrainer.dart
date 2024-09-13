// ignore_for_file: file_names, prefer_final_fields, avoid_print, sort_child_properties_last, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:pinalprojectbark/components/my_list_tile.dart';
import 'package:pinalprojectbark/constants/helper_functions.dart';
import 'package:pinalprojectbark/constants/image_strings.dart';
import 'package:pinalprojectbark/design.dart';
import 'package:pinalprojectbark/pages/ContactUs.dart';
import 'package:pinalprojectbark/pages/Trainer/DogTrainingRequests.dart';
import 'package:pinalprojectbark/pages/Trainer/FeedPage.dart';
import 'package:pinalprojectbark/pages/Trainer/MonthlySchedulePage.dart';
import 'package:pinalprojectbark/pages/Trainer/TrainerRecommendationsPage.dart';
import 'package:pinalprojectbark/pages/Trainer/profilePageTrainer.dart';
import 'package:pinalprojectbark/pages/Trainer/trainer_tasks_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinalprojectbark/pages/Trainer/DogProfileScreen.dart';
import 'package:pinalprojectbark/pages/chat_page.dart';
import 'package:pinalprojectbark/pages/login_page.dart';
import 'package:pinalprojectbark/pages/config.dart';

class HomePageTrainer extends StatefulWidget {
  final String token;
  const HomePageTrainer({required this.token, super.key});

  @override
  State<HomePageTrainer> createState() => _HomePageTrainerState();
}

class _HomePageTrainerState extends State<HomePageTrainer>
    with TickerProviderStateMixin {
  late String email, userName, trainerId;
  late Future<List<dynamic>> _approvedProcesses;
  late TabController _tabController;
  String trainerprofilePicture = '';

  Map<String, List<Map<String, dynamic>>> _workingHours = {};
  Map<String, bool> _dayOff = {};
  DateTime _currentDate = DateTime.now();
  bool _isFetchingSchedule = false;

  @override
  void initState() {
    super.initState();
    final jwtDecodedToken = JwtDecoder.decode(widget.token);
    trainerId = jwtDecodedToken['_id'] as String? ?? 'default_id';
    email = jwtDecodedToken['email'] as String? ?? 'default_email';
    userName = jwtDecodedToken['userName'] as String? ?? 'default_userName';

    fetchTrainerProfilePicture(trainerId).then((profilePictureUrl) {
      setState(() {
        trainerprofilePicture = profilePictureUrl;
      });
    });

    _approvedProcesses = fetchApprovedProcesses();
    _fetchExistingSchedule();
  }

  Future<List<dynamic>> fetchApprovedProcesses() async {
    final response = await http.get(
      Uri.parse('$getApprovedProcesses/$trainerId'),
      headers: {
        "Authorization": "Bearer ${widget.token}",
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse is Map<String, dynamic> &&
          jsonResponse['success'] is List) {
        return jsonResponse['success'];
      } else {
        throw Exception('Unexpected JSON format');
      }
    } else {
      throw Exception('Failed to load approved processes');
    }
  }

  Future<String> fetchTrainerProfilePicture(String trainerId) async {
    try {
      final response = await http.get(
        Uri.parse('$getTrainerProfilePicture/$trainerId'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('Response JSON: $jsonResponse'); // Log the response body

        if (jsonResponse != null && jsonResponse['profilePicture'] != null) {
          return jsonResponse['profilePicture'] as String;
        } else {
          // Return a default profile picture or ID if profilePicture is null
          return 'default_id';
        }
      } else {
        throw Exception('Failed to load trainer profile picture');
      }
    } catch (e) {
      print('Error fetching trainer profile picture: $e');
      return 'default_id'; // Return a default identifier if there's an error
    }
  }

  Future<void> _fetchExistingSchedule() async {
    if (_isFetchingSchedule) return;
    _isFetchingSchedule = true;

    final DateTime weekStart =
        _currentDate.subtract(Duration(days: _currentDate.weekday % 7));

    final response = await http.get(
      Uri.parse(
          '$getScheduleByTutorId/$trainerId?weekStart=${weekStart.toIso8601String()}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null &&
          data['schedule'] != null &&
          data['schedule'].isNotEmpty) {
        setState(() {
          _populateSchedule(data['schedule']);
        });
      } else {
        setState(() {
          _initializeDefaultSchedule();
        });
      }
    } else if (response.statusCode == 404) {
      setState(() {
        _initializeDefaultSchedule();
      });
    } else {
      print('Failed to fetch existing schedule: ${response.body}');
      setState(() {
        _initializeDefaultSchedule();
      });
    }

    _isFetchingSchedule = false;
  }

  void _initializeDefaultSchedule() {
    _workingHours = {};
    _dayOff = {};

    for (var day in _daysOfWeek) {
      _dayOff[day] = true;
      _workingHours[day] = [];
    }
  }

  void _populateSchedule(List<dynamic> scheduleData) {
    _workingHours = {};
    _dayOff = {};

    for (var day in _daysOfWeek) {
      _dayOff[day] = true;
      _workingHours[day] = [];
    }

    for (var entry in scheduleData) {
      final day = entry['day'];
      final times = entry['times'] as List<dynamic>;

      if (times.isNotEmpty) {
        _workingHours[day] = times.map((time) {
          return {
            'startTime': TimeOfDay(
              hour: int.parse(time['startTime'].split(':')[0]),
              minute: int.parse(time['startTime'].split(':')[1]),
            ),
            'endTime': TimeOfDay(
              hour: int.parse(time['endTime'].split(':')[0]),
              minute: int.parse(time['endTime'].split(':')[1]),
            ),
            'available': time['available'],
          };
        }).toList();
        _dayOff[day] = false;
      } else {
        _dayOff[day] = true;
      }
    }
  }

  Future<void> _saveWorkingHours() async {
    final DateTime weekStart =
        _currentDate.subtract(Duration(days: _currentDate.weekday % 7));

    final schedule = _workingHours.map((day, hours) {
      return MapEntry(
        day,
        hours.map((time) {
          return {
            'startTime': (time['startTime'] as TimeOfDay).format(context),
            'endTime': (time['endTime'] as TimeOfDay).format(context),
            'available': time['available'] as bool,
          };
        }).toList(),
      );
    });

    final payload = {
      'tutorId': trainerId,
      'weekStart': weekStart.toIso8601String(),
      'schedule': schedule.entries.map((entry) {
        return {
          'day': entry.key,
          'times': entry.value,
        };
      }).toList(),
    };

    final response = await http.post(
      Uri.parse(createOrUpdateSchedule),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode(payload),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'שעות עבודה נשמרו בהצלחה!',
            style: TextStyle(fontFamily: 'Rubik'),
          ),
          backgroundColor: AppColors.secondaryColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save working hours: ${response.body}',
            style: const TextStyle(fontFamily: 'Rubik'),
          ),
          backgroundColor: AppColors.primaryColor,
        ),
      );
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage(token: widget.token)),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "שלום מאלף $userName ",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.black,
                ),
                onPressed: () async {
                  try {} catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $error'),
                      ),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: Colors.black,
                ),
                onPressed: logout,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'הלקוחות שכרגע באילוף',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Rubik',
                    ),
                  ),
                ),
                FutureBuilder<List<dynamic>>(
                  future: _approvedProcesses,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("${snapshot.error}"));
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      _tabController = TabController(
                        length: snapshot.data!.length,
                        vsync: this,
                      );
                      return Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () {
                                  if (_tabController.index > 0) {
                                    _tabController
                                        .animateTo(_tabController.index - 1);
                                  }
                                },
                              ),
                              Expanded(
                                child: TabBar(
                                  controller: _tabController,
                                  isScrollable: true,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  labelPadding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  tabs: snapshot.data!.map((process) {
                                    return Tab(text: process['dogName']);
                                  }).toList(),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: () {
                                  if (_tabController.index <
                                      _tabController.length - 1) {
                                    _tabController
                                        .animateTo(_tabController.index + 1);
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 130,
                            child: TabBarView(
                              controller: _tabController,
                              children: snapshot.data!.map((process) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DogProfileScreen(
                                          dogId: process['dogId'] ?? '',
                                          token: widget.token,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Card(
                                      color: AppColors.backgroundColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      elevation: 5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            title: Text(
                                              process['dogName'].toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textColor,
                                                fontFamily: 'Rubik',
                                              ),
                                            ),
                                            subtitle: Text(
                                              "שם הבעלים: ${process['userName']}",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: AppColors.textColor,
                                                fontFamily: 'Alef',
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  if (process['_id'] != null &&
                                                      process['trainerId'] !=
                                                          null) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ChatPage(
                                                          token: widget.token,
                                                          chatId:
                                                              process['_id'],
                                                          senderId: process[
                                                              'trainerId'],
                                                          senderType: 'Trainer',
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'נתונים חסרים.'),
                                                      ),
                                                    );
                                                  }
                                                },
                                                icon: const Icon(
                                                  Icons.chat,
                                                  color:
                                                      AppColors.backgroundColor,
                                                ),
                                                label: const Text(
                                                  'צאט אישי',
                                                  style: TextStyle(
                                                    fontFamily: 'Alef',
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.secondaryColor,
                                                  foregroundColor:
                                                      AppColors.backgroundColor,
                                                  fixedSize:
                                                      const Size.fromHeight(35),
                                                ),
                                              ),
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          TrainerTasksPage(
                                                        dogId:
                                                            process['dogId'] ??
                                                                '',
                                                        OwnerId: process[
                                                                'OwnerId'] ??
                                                            '',
                                                        ownerName: process[
                                                                'userName'] ??
                                                            '',
                                                        trainerId: process[
                                                                'trainerId'] ??
                                                            '',
                                                        trainerName: process[
                                                                'trainerName'] ??
                                                            '',
                                                        dogName: process[
                                                                'dogName'] ??
                                                            '',
                                                        token: widget.token,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.home,
                                                  color:
                                                      AppColors.backgroundColor,
                                                ),
                                                label: const Text(
                                                  'אימון ביתי',
                                                  style: TextStyle(
                                                    fontFamily: 'Alef',
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.accentColor,
                                                  foregroundColor:
                                                      AppColors.backgroundColor,
                                                  fixedSize:
                                                      const Size.fromHeight(35),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text("${snapshot.error}"));
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'הגדר שעות עבודה שבועיות',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Rubik',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: _daysOfWeek.map((day) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _dayOff[day] ?? false,
                                    onChanged: (value) {
                                      setState(() {
                                        _dayOff[day] = value!;
                                        if (value) {
                                          _workingHours.remove(day);
                                        } else {
                                          _workingHours[day] = [];
                                        }
                                      });
                                    },
                                    activeColor: AppColors.accentColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '$day (${_getFormattedDateForDay(day)})',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Rubik',
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_dayOff[day] == true)
                                const Padding(
                                  padding: EdgeInsets.only(right: 48.0),
                                  child: Text(
                                    'יום חופש',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Alef',
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.only(right: 48.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: _buildTimeSlotsForDay(day),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                ElevatedButton(
                  onPressed: _saveWorkingHours,
                  child: const Text('שמור שעות עבודה'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.backgroundColor,
                    backgroundColor: AppColors.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          drawer: TrainerDrawer(
              token: widget.token,
              trainerprofilePicture: trainerprofilePicture),
        ),
      ),
    );
  }

  List<String> get _daysOfWeek => [
        'יום ראשון',
        'יום שני',
        'יום שלישי',
        'יום רביעי',
        'יום חמישי',
        'יום שישי',
        'שבת',
      ];

  String _getFormattedDateForDay(String day) {
    final currentWeekdayIndex = _daysOfWeek.indexOf(day);
    final date = DateTime.now().add(Duration(days: currentWeekdayIndex));
    return '${date.day}/${date.month}';
  }

  List<Widget> _buildTimeSlotsForDay(String day) {
    List<Widget> timeSlotsColumn1 = [];
    List<Widget> timeSlotsColumn2 = [];

    for (var i = 8; i < 22; i++) {
      final startTime = TimeOfDay(hour: i, minute: 0);
      final endTime = TimeOfDay(hour: i, minute: 45);

      bool isSlotSelected = _workingHours[day]?.any((slot) =>
              (slot['startTime'] as TimeOfDay) == startTime &&
              (slot['available'] as bool)) ??
          false;

      final timeSlot = Container(
        margin:
            const EdgeInsets.symmetric(vertical: 2.0), // Minimal vertical space
        child: Row(
          children: [
            Checkbox(
              value: isSlotSelected,
              onChanged: (value) {
                setState(() {
                  if (_workingHours[day] == null) {
                    _workingHours[day] = [];
                  }

                  final existingSlot = _workingHours[day]?.firstWhere(
                      (slot) => (slot['startTime'] as TimeOfDay) == startTime,
                      orElse: () => {});

                  if (existingSlot != null && existingSlot.isNotEmpty) {
                    existingSlot['available'] = value!;
                    if (!value) {
                      _workingHours[day]?.remove(existingSlot);
                    }
                  } else if (value == true) {
                    _workingHours[day]?.add({
                      'startTime': startTime,
                      'endTime': endTime,
                      'available': value!,
                    });
                  }
                });
              },
              activeColor: AppColors.accentColor,
            ),
            const SizedBox(width: 4),
            Text(
              '${startTime.format(context)} - ${endTime.format(context)}',
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Alef',
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
      );

      if (i < 15) {
        timeSlotsColumn1.add(timeSlot);
      } else {
        timeSlotsColumn2.add(timeSlot);
      }
    }

    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: timeSlotsColumn1,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: timeSlotsColumn2,
            ),
          ),
        ],
      ),
    ];
  }
}

class TrainerDrawer extends StatelessWidget {
  final String token;
  final String trainerprofilePicture;

  const TrainerDrawer(
      {Key? key, required this.token, required this.trainerprofilePicture})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    late String roleU, userName, trainerId;
    final dark = THelperFunctions.isDarkMode(context);

    final jwtDecodedToken = JwtDecoder.decode(token);
    trainerId = jwtDecodedToken['_id'] ?? 'default_id';
    userName = jwtDecodedToken['userName'] ?? 'default_userName';
    roleU = jwtDecodedToken['role'] ?? 'default_role';

    return Drawer(
      backgroundColor: AppColors.primaryColor.withOpacity(0.8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const SizedBox(height: 80),
              Image(
                height: 150,
                image: AssetImage(
                  dark ? TImages.lightAppLogo : TImages.darkAppLogo,
                ),
              ),
              MyListTile(
                icon: Icons.home,
                text: 'בית',
                onTap: () => Navigator.pop(context),
              ),
              MyListTile(
                icon: Icons.person,
                text: 'פרופיל',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePageTrainer(token: token),
                  ),
                ),
              ),
              MyListTile(
                icon: Icons.sports_kabaddi,
                text: 'הבקשות שלי',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DogTrainingRequests(token: token),
                  ),
                ),
              ),
              MyListTile(
                icon: Icons.post_add,
                text: 'פוסטים של מאלפים',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return FeedPage(
                        token: token,
                        userId: trainerId,
                        userName: userName,
                        role: "trainer",
                        profilePicture: trainerprofilePicture,
                      );
                    },
                  ),
                ),
              ),
              MyListTile(
                icon: Icons.event,
                text: 'פגישות שבועיות',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return MonthlySchedulePage(
                        token: token,
                        tutorId: trainerId,
                      );
                    },
                  ),
                ),
              ),
              MyListTile(
                icon: Icons.star_half,
                text: 'המלצות שלי',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return TrainerRecommendationsPage(
                        token: token,
                        trainerId: trainerId,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                MyListTile(
                  icon: Icons.contact_mail,
                  text: 'צור קשר',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactUs(
                        token: token,
                        userId: trainerId,
                        userName: userName,
                        roleU: roleU,
                      ),
                    ),
                  ),
                ),
                MyListTile(
                  icon: Icons.logout,
                  text: 'התנתקות',
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => LoginPage(token: token)),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
