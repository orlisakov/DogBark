// ignore_for_file: file_names, use_build_context_synchronously, prefer_typing_uninitialized_variables, non_constant_identifier_names, sort_child_properties_last, unused_field, unused_local_variable
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:pinalprojectbark/constants/section_heading.dart';
import 'package:pinalprojectbark/constants/sizes.dart';
import 'package:pinalprojectbark/design.dart';
import 'package:pinalprojectbark/pages/recommendations_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('ProfilePage');

class TrainerProfileScreen extends StatefulWidget {
  final token;
  final Map<String, dynamic> trainerData;
  const TrainerProfileScreen(
      {Key? key, required this.trainerData, @required this.token})
      : super(key: key);

  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreenState();
}

//------------------------------------------------------------------------------
class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  late String OwnerId, trainerId, userName, trainerName;
  late bool _requestSent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _requestSent = false;
    _loadRequestSentState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    OwnerId = jwtDecodedToken['_id'] ?? 'OwnerId';
    userName = jwtDecodedToken['userName'] ?? 'userName';
    trainerId = widget.trainerData['userId'] ?? 'trainers';
    trainerName = widget.trainerData['FirstName'] ?? 'userName';
  }

  //----------------------------------------------------------------------
  Future<void> _loadRequestSentState() async {
    final prefs = await SharedPreferences.getInstance();
    String requestKey = "request_${OwnerId}_to_$trainerId";
    bool requestSent = prefs.getBool(requestKey) ?? false;
    setState(() {
      _requestSent = requestSent;
      _isLoading = false;
    });
  }

  //----------------------------------------------------------------------
  Future<void> _saveRequestSentState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    String requestKey = "request_${OwnerId}_to_$trainerId";
    await prefs.setBool(requestKey, value);
  }

  //----------------------------------------------------------------------
  Future<void> _requestTraining(BuildContext context) async {
    final Map<String, String>? selectedDogInfo =
        await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => DogSelectionDialog(token: widget.token),
    );
    final selectedDogId = selectedDogInfo?['id'] ?? '';
    final selectedDogName = selectedDogInfo?['name'] ?? '';

    if (selectedDogId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Invalid dog selected. Please try again.")),
      );
      return;
    }

    if (selectedDogInfo != null) {
      final bool alreadyWorkingTogether =
          await _checkIfWorkingTogether(OwnerId, trainerId, selectedDogId);
      if (alreadyWorkingTogether) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'הבקשה התבטלה',
                textAlign: TextAlign.right,
              ),
              content: const Text(
                "אתה כבר בתהליך אילוף עם הכלב הזה והמאלף הזה",
                textAlign: TextAlign.right,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('אישור'),
                ),
              ],
            );
          },
        );
        return;
      } else {
        try {
          final response = await http.post(
            Uri.parse(createGeneralTrainingRequests),
            headers: <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode(<String, String>{
              'OwnerId': OwnerId,
              'userName': userName,
              'trainerId': trainerId,
              'trainerName': trainerName,
              'dogId': selectedDogId,
              'dogName': selectedDogName,
            }),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: AppColors.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  title: const Text(
                    'בקשה נשלחה',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  content: const Text(
                    '!בקשת האילוף נשלחה בהצלחה',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontFamily: 'Alef',
                      fontSize: 18,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'אישור',
                        style: TextStyle(
                          color: AppColors.accentColor,
                          fontFamily: 'Rubik',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
            await _saveRequestSentState(true);
            setState(() {
              _requestSent = true;
            });

            // Now, create a trainer message
            try {
              final messageResponse = await http.post(
                Uri.parse(trainerMessages),
                headers: <String, String>{'Content-Type': 'application/json'},
                body: jsonEncode(<String, String>{
                  'OwnerId': OwnerId,
                  'userName': userName,
                  'trainerId': trainerId,
                  'trainerName': trainerName,
                  'dogId': selectedDogId,
                  'dogName': selectedDogName,
                  'message': " בקשה חדשה לאילוף הוגשה -> צפה בבקשות שלי",
                }),
              );

              if (messageResponse.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("ההודעה נשלחה למאלף!")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Failed to send message to trainer.")),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        "An error occurred while sending message to trainer. Error: $e")),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    "Failed to send training request. Please try again.")));
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("An error occurred. Please try again. Error: $e")));
        }
      }
    } else {
      // Handle request deletion logic here
      try {
        if (selectedDogId.isNotEmpty) {
          final response = await http.post(
            Uri.parse(deleteGeneralTrainingRequest),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8'
            },
            body: jsonEncode(<String, String>{
              'OwnerId': OwnerId,
              'dogId': selectedDogId,
            }),
          );

          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Training request deleted successfully.")));
            _saveRequestSentState(false).then((_) {
              setState(() {
                _requestSent = false;
              });
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    "Failed to delete training request. Please try again.")));
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("An error occurred. Please try again. Error: $e")));
      }
    }
  }

  //----------------------------------------------------------------------
  Future<bool> _checkIfWorkingTogether(
      String OwnerId, String trainerId, String dogId) async {
    try {
      final response = await http.get(
        Uri.parse('$checkIfWorkingTogether/$OwnerId/$trainerId/$dogId'),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['isWorkingTogether'] ?? false;
      } else {
        throw Exception('Failed to check if working together');
      }
    } catch (e) {
      //print("Error checking if working together: $e");
      return false;
    }
  }

  //-----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            " פרופיל מאלף",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Rubik',
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row containing the Training Request and Recommendations Page buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_box),
                          onPressed: () => _requestTraining(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          label: const Text(
                            "בקשה לאילוף",
                            style: TextStyle(fontFamily: 'Alef'),
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.thumb_up),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecommendationsPage(
                                  trainerId: trainerId,
                                  ownerId: OwnerId,
                                  ownerName: userName,
                                  token: widget.token,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          label: const Text(
                            "דף המלצות",
                            style: TextStyle(fontFamily: 'Alef'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Profile picture and change button
                    Center(
                      child: _buildProfilePictureCard(
                          widget.trainerData['profilePicture']),
                    ),
                    const SizedBox(height: 20),

                    // Basic Info Section
                    _buildSectionWithHeading(context, 'מידע בסיסי:', [
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.person,
                          'שם פרטי:',
                          widget.trainerData['FirstName'] as String? ?? ''),
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.person_outline,
                          'שם משפחה:',
                          widget.trainerData['LastName'] as String? ?? ''),
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.phone,
                          'מספר טלפון:',
                          widget.trainerData['PhoneNum'] as String? ?? ''),
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.location_on,
                          'איזור עבודה:',
                          widget.trainerData['Area'] as String? ?? ''),
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.badge,
                          'הסמכות מקצועיות או השתייכות:',
                          widget.trainerData['Question1'] as String? ?? ''),
                    ]),

                    // Experience and Expertise Section
                    _buildSectionWithHeading(context, 'ניסיון ומומחיות:', [
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.work,
                          'כמה שנות ניסיון יש לך כמאלף כלבים?',
                          widget.trainerData['Question2'] as String? ?? ''),
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.pets,
                          'עם אילו גזעים יש לך ניסיון בעבודה?',
                          widget.trainerData['Question3'] as String? ?? ''),
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.school,
                          'האם אתה מתמחה בטכניקות או מתודולוגיות אימון ספציפיות?',
                          widget.trainerData['Question4'] as String? ?? ''),
                    ]),

                    // Philosophy Section
                    _buildSectionWithHeading(context, 'פילוסופיית האימון:', [
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.psychology,
                          'תאר את פילוסופיית האימון והגישה שלך.',
                          widget.trainerData['Question5'] as String? ?? ''),
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.lightbulb,
                          'האם אתה נוטה יותר לחיזוק חיובי, אימון קליקים או שיטות אחרות?',
                          widget.trainerData['Question6'] as String? ?? ''),
                    ]),

                    // Services Offered Section
                    _buildSectionWithHeading(context, 'שירותים המוצעים:', [
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.local_offer,
                          'ציין את סוגי שירותי האימון שאתה מציע.',
                          widget.trainerData['Question7'] as String? ?? ''),
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.group,
                          'האם אתה זמין לשיעורים קבוצתיים, למפגשים פרטיים או לשניהם?',
                          widget.trainerData['Question8'] as String? ?? ''),
                    ]),

                    // Success Stories Section
                    _buildSectionWithHeading(context, 'סיפורי הצלחה:', [
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.star,
                          'שתף כמה סיפורי הצלחה או המלצות מלקוחות קודמים.',
                          widget.trainerData['Question9'] as String? ?? ''),
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.emoji_events,
                          'הדגש את כל ההישגים הבולטים בקריירת אילוף הכלבים שלך.',
                          widget.trainerData['Question10'] as String? ?? ''),
                    ]),

                    // Availability Section
                    _buildSectionWithHeading(context, 'זמינות:', [
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.calendar_today,
                          'ציין את זמינותך לאימונים.',
                          widget.trainerData['Question11'] as String? ?? ''),
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.location_pin,
                          'האם אתה מוכן לנסוע למקומות של לקוחות להדרכות?',
                          widget.trainerData['Question12'] as String? ?? ''),
                    ]),

                    // Training Location Section
                    _buildSectionWithHeading(context, 'מיקום ההדרכה:', [
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.location_city,
                          'היכן אתה בדרך כלל עורך אימונים?',
                          widget.trainerData['Question13'] as String? ?? ''),
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.home_work,
                          'האם יש לך גישה למתקן אימונים או לציוד ספציפי?',
                          widget.trainerData['Question14'] as String? ?? ''),
                    ]),

                    // Training Tools Section
                    _buildSectionWithHeading(context, 'כלי הדרכה:', [
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.build,
                          'באילו כלים או ציוד אתה משתמש בדרך כלל באימונים?',
                          widget.trainerData['Question15'] as String? ?? ''),
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.not_interested,
                          'האם יש כלים שאתה מעדיף לא להשתמש בהם?',
                          widget.trainerData['Question16'] as String? ?? ''),
                    ]),

                    // Group Dynamics Section
                    _buildSectionWithHeading(context, 'דינמיקה קבוצתית:', [
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.groups,
                          'תאר את הגישה שלך לניהול אימונים קבוצתיים.',
                          widget.trainerData['Question17'] as String? ?? ''),
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.group_work,
                          'איך מטפלים בכלבים בעלי מזג משתנה במסגרת קבוצתית?',
                          widget.trainerData['Question18'] as String? ?? ''),
                    ]),

                    // Continuous Education Section
                    _buildSectionWithHeading(context, 'השכלה מתמשכת:', [
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.school,
                          'איך אתה נשאר מעודכן בטכניקות ובמחקר העדכניים של אילוף כלבים?',
                          widget.trainerData['Question19'] as String? ?? ''),
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.business_center,
                          'האם השתתפת לאחרונה בסדנאות, סמינרים או כנסים הקשורים לאילוף כלבים?',
                          widget.trainerData['Question20'] as String? ?? ''),
                    ]),

                    // Client Communication Section
                    _buildSectionWithHeading(context, 'תקשורת לקוח:', [
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.chat,
                          'איך אתה מתקשר עם לקוחות בין הפגישות?',
                          widget.trainerData['Question21'] as String? ?? ''),
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.feedback,
                          'האם אתה פתוח לקבל משוב מלקוחות?',
                          widget.trainerData['Question22'] as String? ?? ''),
                    ]),

                    // Costs and Policies Section
                    _buildSectionWithHeading(context, 'עלויות ומדיניות:', [
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.attach_money,
                          'ציין את העמלות שלך וכל אפשרויות החבילה הזמינות.',
                          widget.trainerData['Question23'] as String? ?? ''),
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.policy,
                          'תאר את מדיניות הביטול או תזמון מחדש שלך.',
                          widget.trainerData['Question24'] as String? ?? ''),
                    ]),

                    // References Section
                    _buildSectionWithHeading(context, 'הפניות:', [
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.book,
                          'האם אתה יכול לספק הפניות מלקוחות קודמים או עמיתים בתעשייה?',
                          widget.trainerData['Question25'] as String? ?? ''),
                    ]),

                    // Insurance and Liability Section
                    _buildSectionWithHeading(context, 'ביטוח ואחריות:', [
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.shield,
                          'יש לך ביטוח אחריות?',
                          widget.trainerData['Question26'] as String? ?? ''),
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.security,
                          'האם יש אחריות או אמצעי בטיחות ספציפיים שלקוחות צריכים להיות מודעים אליהם?',
                          widget.trainerData['Question27'] as String? ?? ''),
                    ]),

                    // Personal Approach Section
                    _buildSectionWithHeading(context, 'גישה אישית:', [
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.favorite,
                          'מה מייחד אותך כמאלף כלבים?',
                          widget.trainerData['Question28'] as String? ?? ''),
                      _buildQuestionAnswerWithIcon(
                          context,
                          Icons.pets,
                          'איך יוצרים קרבה גם עם הכלבים וגם עם בעליהם?',
                          widget.trainerData['Question29'] as String? ?? ''),
                    ]),

                    // Certifications Section
                    _buildSectionWithHeading(context, 'הסמכות ואישורים:', [
                      _buildCertificatesList(
                          widget.trainerData['certificates']),
                    ]),
                  ],
                ),
              ),
      ),
    );
  }
}

//------------------------------------------------------------------------------
Widget _buildCertificatesList(dynamic certificates) {
  if (certificates == null || certificates.isEmpty) {
    return const Text('אין הסמכות להציג.');
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: certificates.map<Widget>((certificate) {
      final formattedUrl =
          'http://192.168.70.1:3000/${certificate.replaceAll('\\', '/')}';
      return Padding(
        padding: const EdgeInsets.only(bottom: TSizes.defaultSpace),
        child: Image.network(
          formattedUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            _logger.warning('Failed to load certificate image: $error');
            return const Icon(Icons.error, size: 100);
          },
        ),
      );
    }).toList(),
  );
}

//------------------------------------------------------------------------------
Widget _buildSectionWithHeading(
    BuildContext context, String title, List<Widget> content) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10.0),
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15.0),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8.0,
          spreadRadius: 2.0,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextStyle(
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Rubik',
          ),
          child: TSectionHeading(
            title: title,
            showActionButton: false,
          ),
        ),
        ...content,
      ],
    ),
  );
}

//------------------------------------------------------------------------------
Widget _buildQuestionAnswerWithIcon(
    BuildContext context, IconData icon, String question, String? answer) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5.0),
    child: Row(
      children: [
        Icon(icon, color: AppColors.accentColor),
        const SizedBox(width: 10),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$question ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Rubik',
                    ),
                  ),
                  TextSpan(
                    text: answer ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'Alef',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

//------------------------------------------------------------------------------
Widget _buildProfilePictureCard(String? imageUrl) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.network(
                'http://192.168.70.1:3000/${imageUrl.replaceAll('\\', '/')}',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  _logger.warning('Failed to load profile picture: $error');
                  return const Icon(Icons.error, size: 150);
                },
              ),
            )
          : const Icon(Icons.person, size: 150, color: Colors.grey),
    ),
  );
}

//------------------------------------------------------------------------------
class DogSelectionDialog extends StatelessWidget {
  final String token;

  const DogSelectionDialog({Key? key, required this.token}) : super(key: key);

  Future<List<dynamic>> _fetchDogs() async {
    try {
      final ownerId = JwtDecoder.decode(token)['_id'];
      final uri = Uri.parse('$getDogProfileByOwnerId/$ownerId');
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        throw Exception('Failed to load dogs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch dogs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'בחר כלב',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.textColor,
              fontFamily: 'Rubik',
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.pets, color: AppColors.accentColor),
        ],
      ),
      content: FutureBuilder<List<dynamic>>(
        future: _fetchDogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(
                color: Colors.red,
                fontFamily: 'Alef',
              ),
              textAlign: TextAlign.center,
            );
          } else {
            final dogs = snapshot.data!;
            return SizedBox(
              height: 200,
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: dogs.length,
                itemBuilder: (context, index) {
                  final dog = dogs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      trailing:
                          const Icon(Icons.pets, color: AppColors.primaryColor),
                      title: Text(
                        dog['DogName'],
                        style: TextStyle(
                          fontFamily: 'Alef',
                          fontSize: 16.sp,
                          color: AppColors.textColor,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      subtitle: Text(
                        'גזע: ${dog['Race'] ?? 'לא ידוע'}',
                        style: TextStyle(
                          fontFamily: 'Alef',
                          fontSize: 14.sp,
                          color: AppColors.textColor.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.right,
                      ),
                      onTap: () => Navigator.of(context).pop({
                        'id': dog['_id'].toString(),
                        'name': dog['DogName'].toString(),
                      }),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'ביטול',
            style: TextStyle(
              color: Colors.red,
              fontFamily: 'Rubik',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
