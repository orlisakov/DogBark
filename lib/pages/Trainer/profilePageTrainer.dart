// ignore_for_file: file_names, avoid_print
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pinalprojectbark/constants/sizes.dart';
import 'package:pinalprojectbark/pages/Trainer/multi_step_form_trainer.dart';
import 'package:pinalprojectbark/pages/config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:pinalprojectbark/design.dart';

final Logger _logger = Logger('ProfilePage');

class ProfilePageTrainer extends StatefulWidget {
  final String token;
  const ProfilePageTrainer({required this.token, super.key});

  @override
  State<ProfilePageTrainer> createState() => _ProfilePageTrainerState();
}

class _ProfilePageTrainerState extends State<ProfilePageTrainer> {
  late String userId;
  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
    if (widget.token.isNotEmpty) {
      Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
      userId = jwtDecodedToken['_id'] ?? '';

      if (userId.isNotEmpty) {
        getProfileTrainerList(userId);
      } else {
        redirectToLogin();
      }
    } else {
      redirectToLogin();
    }
  }

  void redirectToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MultiStepFormTrainer(token: widget.token, profileData: const {}),
      ),
    );
  }

  void getProfileTrainerList(userId) async {
    var regBody = {"userId": userId};

    try {
      var response = await http.post(
        Uri.parse(trainerProfileList),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] != null &&
          jsonResponse['success'].isNotEmpty) {
        setState(() {
          items = jsonResponse['success'];
        });
      } else {
        _logger.warning('Profile not found.');
        redirectToMultiStepFormTrainer();
      }
    } catch (e) {
      _logger.severe("HTTP request failed: $e");
      redirectToMultiStepFormTrainer();
    }
  }

  void redirectToMultiStepFormTrainer() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) =>
              MultiStepFormTrainer(token: widget.token, profileData: const {})),
      (Route<dynamic> route) => false,
    );
  }

  void deleteItem(id) async {
    var regBody = {"id": id};

    var response = await http.post(
      Uri.parse(deleteTrainerProfile),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(regBody),
    );

    var jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      getProfileTrainerList(userId);
    }
  }

  void updateProfile(Map<String, dynamic> profileData) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MultiStepFormTrainer(token: widget.token, profileData: profileData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            " דף פרופיל מאלף",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Rubik',
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
        ),
        body: Column(
          children: [
            const SizedBox(height: 50),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, int index) {
                  _logger.info("Item at index $index: ${items[index]}");
                  return Card(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(TSizes.defaultSpace),
                          child: Column(
                            children: [
                              // Profile picture and change button
                              SizedBox(
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    if (items[index]['profilePicture'] !=
                                            null &&
                                        items[index]['profilePicture']
                                            .isNotEmpty)
                                      _buildProfilePicture(
                                          items[index]['profilePicture']),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => updateProfile(items[index]),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: AppColors.secondaryColor,
                                ),
                                child: const Text('עדכן פרופיל'),
                              ),
                              const SizedBox(height: TSizes.spaceBtwItems),
                              _buildSectionWithHeading(
                                  context,
                                  'מידע בסיסי:',
                                  [
                                    _buildQuestionAnswer(
                                        context,
                                        'שם פרטי:',
                                        items[index]['FirstName'] as String? ??
                                            ''),
                                    _buildQuestionAnswer(
                                        context,
                                        'שם משפחה:',
                                        items[index]['LastName'] as String? ??
                                            ''),
                                    _buildQuestionAnswer(
                                        context,
                                        'מספר טלפון:',
                                        items[index]['PhoneNum'] as String? ??
                                            ''),
                                    _buildQuestionAnswer(context, 'איזור עבודה',
                                        items[index]['Area'] as String? ?? ''),
                                    _buildQuestionAnswer(
                                        context,
                                        'הסמכות מקצועיות או השתייכות.',
                                        items[index]['Question1'] as String? ??
                                            ''),
                                  ],
                                  Icons.account_box),
                              _buildSectionWithHeading(
                                  context,
                                  'ניסיון ומומחיות:',
                                  [
                                    _buildQuestionAnswer(
                                        context,
                                        'כמה שנות ניסיון יש לך כמאלף כלבים?',
                                        items[index]['Question2'] as String? ??
                                            ''),
                                    _buildQuestionAnswer(
                                        context,
                                        'עם אילו גזעים יש לך ניסיון בעבודה?',
                                        items[index]['Question3'] as String? ??
                                            ''),
                                    _buildQuestionAnswer(
                                        context,
                                        'האם אתה מתמחה בטכניקות או מתודולוגיות אימון ספציפיות?',
                                        items[index]['Question4'] as String? ??
                                            ''),
                                  ],
                                  Icons.star),
                              _buildSectionWithHeading(
                                  context,
                                  'פילוסופיית האימון:',
                                  [
                                    _buildQuestionAnswer(
                                        context,
                                        'תאר את פילוסופיית האימון והגישה שלך.',
                                        items[index]['Question5'] as String? ??
                                            ''),
                                    _buildQuestionAnswer(
                                        context,
                                        'האם אתה נוטה יותר לחיזוק חיובי, אימון קליקים או שיטות אחרות?',
                                        items[index]['Question6'] as String? ??
                                            ''),
                                  ],
                                  Icons.psychology),
                              _buildSectionWithHeading(
                                  context,
                                  'שירותים המוצעים:',
                                  [
                                    _buildQuestionAnswer(
                                        context,
                                        'ציין את סוגי שירותי האימון שאתה מציע (למשל, צייתנות בסיסית, שינוי התנהגות, אימון זריזות).',
                                        items[index]['Question7'] as String? ??
                                            ''),
                                    _buildQuestionAnswer(
                                        context,
                                        'האם אתה זמין לשיעורים קבוצתיים, למפגשים פרטיים או לשניהם?',
                                        items[index]['Question8'] as String? ??
                                            ''),
                                  ],
                                  Icons.handshake),
                              _buildSectionWithHeading(
                                  context,
                                  'סיפורי הצלחה:',
                                  [
                                    _buildQuestionAnswer(
                                        context,
                                        'שתף כמה סיפורי הצלחה או המלצות מלקוחות קודמים (אם רלוונטי).',
                                        items[index]['Question9'] as String? ??
                                            ''),
                                    _buildQuestionAnswer(
                                        context,
                                        'הדגש את כל ההישגים הבולטים בקריירת אילוף הכלבים שלך.',
                                        items[index]['Question10'] as String? ??
                                            ''),
                                  ],
                                  Icons.thumb_up),
                              _buildSectionWithHeading(
                                  context,
                                  'זמינות:',
                                  [
                                    _buildQuestionAnswer(
                                        context,
                                        'ציין את זמינותך לאימונים.',
                                        items[index]['Question11'] as String? ??
                                            ''),
                                    _buildQuestionAnswer(
                                        context,
                                        'האם אתה מוכן לנסוע למקומות של לקוחות להדרכות?',
                                        items[index]['Question12'] as String? ??
                                            ''),
                                  ],
                                  Icons.access_time),
                              _buildSectionWithHeading(
                                  context,
                                  'מיקום ההדרכה:',
                                  [
                                    _buildQuestionAnswer(
                                        context,
                                        'היכן אתה בדרך כלל עורך אימונים? (לדוגמה, במתקן שלך, בבית הלקוח, בגנים ציבוריים)',
                                        items[index]['Question13'] as String? ??
                                            ''),
                                    _buildQuestionAnswer(
                                        context,
                                        'האם יש לך גישה למתקן אימונים או לציוד ספציפי?',
                                        items[index]['Question14'] as String? ??
                                            ''),
                                  ],
                                  Icons.location_on),
                              _buildSectionWithHeading(
                                  context,
                                  'כלי הדרכה:',
                                  [
                                    _buildQuestionAnswer(
                                        context,
                                        'באילו כלים או ציוד אתה משתמש בדרך כלל באימונים?',
                                        items[index]['Question15'] as String? ??
                                            ''),
                                    _buildQuestionAnswer(
                                        context,
                                        'האם יש כלים שאתה מעדיף לא להשתמש בהם?',
                                        items[index]['Question16'] as String? ??
                                            ''),
                                  ],
                                  Icons.build),
                              _buildSectionWithHeading(
                                  context,
                                  'דינמיקה קבוצתית:',
                                  [
                                    _buildQuestionAnswer(
                                        context,
                                        'אם ישים, תאר את הגישה שלך לניהול אימונים קבוצתיים.',
                                        items[index]['Question17'] as String? ??
                                            ''),
                                    _buildQuestionAnswer(
                                        context,
                                        'איך מטפלים בכלבים בעלי מזג משתנה במסגרת קבוצתית?',
                                        items[index]['Question18'] as String? ??
                                            ''),
                                  ],
                                  Icons.group),
                              _buildSectionWithHeading(
                                  context,
                                  'השכלה מתמשכת:',
                                  [
                                    _buildQuestionAnswer(
                                        context,
                                        'איך אתה נשאר מעודכן בטכניקות ובמחקר העדכניים של אילוף כלבים?',
                                        items[index]['Question19'] as String? ??
                                            ''),
                                    _buildQuestionAnswer(
                                        context,
                                        'האם השתתפת לאחרונה בסדנאות, סמינרים או כנסים הקשורים לאילוף כלבים?',
                                        items[index]['Question20'] as String? ??
                                            ''),
                                  ],
                                  Icons.school),
                              _buildSectionWithHeading(
                                  context,
                                  'תקשורת לקוח:',
                                  [
                                    _buildQuestionAnswer(
                                        context,
                                        'איך אתה מתקשר עם לקוחות בין הפגישות?',
                                        items[index]['Question21'] as String? ??
                                            ''),
                                    _buildQuestionAnswer(
                                        context,
                                        'האם אתה פתוח לקבל משוב מלקוחות?',
                                        items[index]['Question22'] as String? ??
                                            ''),
                                  ],
                                  Icons.message),
                              _buildSectionWithHeading(
                                  context,
                                  'עלויות ומדיניות:',
                                  [
                                    _buildQuestionAnswer(
                                        context,
                                        'ציין את העמלות שלך וכל אפשרויות החבילה הזמינות.',
                                        items[index]['Question23'] as String? ??
                                            ''),
                                    _buildQuestionAnswer(
                                        context,
                                        'תאר את מדיניות הביטול או תזמון מחדש שלך.',
                                        items[index]['Question24'] as String? ??
                                            ''),
                                  ],
                                  Icons.monetization_on),
                              _buildSectionWithHeading(
                                  context,
                                  'הפניות:',
                                  [
                                    _buildQuestionAnswer(
                                        context,
                                        'האם אתה יכול לספק הפניות מלקוחות קודמים או עמיתים בתעשייה?',
                                        items[index]['Question25'] as String? ??
                                            ''),
                                  ],
                                  Icons.contact_page),
                              _buildSectionWithHeading(
                                  context,
                                  'ביטוח ואחריות:',
                                  [
                                    _buildQuestionAnswer(
                                        context,
                                        'יש לך ביטוח אחריות?',
                                        items[index]['Question26'] as String? ??
                                            ''),
                                    _buildQuestionAnswer(
                                        context,
                                        'האם יש אחריות או אמצעי בטיחות ספציפיים שלקוחות צריכים להיות מודעים אליהם?',
                                        items[index]['Question27'] as String? ??
                                            ''),
                                  ],
                                  Icons.verified_user),
                              _buildSectionWithHeading(
                                  context,
                                  'גישה אישית:',
                                  [
                                    _buildQuestionAnswer(
                                        context,
                                        'מה מייחד אותך כמאלף כלבים?',
                                        items[index]['Question28'] as String? ??
                                            ''),
                                    _buildQuestionAnswer(
                                        context,
                                        'איך יוצרים קרבה גם עם הכלבים וגם עם בעליהם?',
                                        items[index]['Question29'] as String? ??
                                            ''),
                                  ],
                                  Icons.person),
                              // Certificates and authorizations section
                              _buildSectionWithHeading(
                                  context,
                                  'הסמכות ואישורים:',
                                  [
                                    _buildCertificatesList(
                                        items[index]['certificates']),
                                  ],
                                  Icons.school),
                              const SizedBox(height: TSizes.defaultSpace),
                              ElevatedButton(
                                onPressed: () {
                                  deleteItem(items[index]['_id']);
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('מחק פרופיל'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture(String imageUrl) {
    final formattedUrl =
        'http://192.168.70.1:3000/${imageUrl.replaceAll('\\', '/')}';

    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0), // קצוות מעוגלות
        border: Border.all(
          color: AppColors.accentColor, // צבע המסגרת
          width: 3.0, // עובי המסגרת
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0), // קצוות מעוגלות
        child: Image.network(
          formattedUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Log the error
            _logger.warning('Failed to load profile picture: $error');
            // Return a placeholder or error widget
            return const Icon(Icons.error, size: 100);
          },
        ),
      ),
    );
  }

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

  Widget _buildSectionWithHeading(
      BuildContext context, String title, List<Widget> content, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4,
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.accentColor),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Rubik',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        children: content,
      ),
    );
  }

  Widget _buildQuestionAnswer(
      BuildContext context, String question, String? answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "$question ",
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              TextSpan(
                text: answer ?? 'N/A', // Display 'N/A' if answer is null
                style: const TextStyle(
                  fontFamily: 'OpenSans',
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
