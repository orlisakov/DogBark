// ignore_for_file: file_names, use_build_context_synchronously, prefer_typing_uninitialized_variables, non_constant_identifier_names, sort_child_properties_last, unused_field, avoid_print
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pinalprojectbark/constants/section_heading.dart';
import 'package:pinalprojectbark/pages/owner/profilePageOwner.dart';
import 'dart:convert';
import '../config.dart';
import 'package:pinalprojectbark/design.dart'; 

class DogProfileScreen extends StatefulWidget {
  final token;
  final String dogId;

  const DogProfileScreen({Key? key, required this.dogId, @required this.token})
      : super(key: key);

  @override
  State<DogProfileScreen> createState() => _DogProfileScreenState();
}

class _DogProfileScreenState extends State<DogProfileScreen> {
  late Future<Map<String, dynamic>> dogProfile;

  @override
  void initState() {
    super.initState();
    dogProfile = fetchDogProfile(widget.dogId);
  }

  Future<Map<String, dynamic>> fetchDogProfile(String dogId) async {
    final response = await http.get(
      Uri.parse('$getDogProfileById/$dogId'),
      headers: {
        "Authorization": "Bearer ${widget.token}",
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load dog profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            "פרופיל כלב",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Rubik',
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<Map<String, dynamic>>(
            future: dogProfile,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                // Once data is available, it's accessed through snapshot.data
                final profileData = snapshot.data!;
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            if (profileData['dogImage'] != null &&
                                profileData['dogImage'].isNotEmpty)
                              Wrap(
                                spacing: 8.0,
                                children: (profileData['dogImage'] as List)
                                    .map((mediaUrl) {
                                  return _buildMediaWidget({
                                    'type': mediaUrl.endsWith('.mp4')
                                        ? 'video'
                                        : 'image',
                                    'url': 'http://192.168.70.1:3000/$mediaUrl'
                                  });
                                }).toList(),
                              )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionWithHeading(context, 'מידע בסיסי', [
                        _buildQuestionAnswerWithIcon(context, Icons.pets,
                            'שם הכלב:', profileData['DogName']),
                        _buildQuestionAnswerWithIcon(context, Icons.category,
                            'גזע:', profileData['Race']),
                        _buildQuestionAnswerWithIcon(context, Icons.line_weight,
                            'משקל:', profileData['Weight']),
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.home,
                            'האם הכלב מאומץ מעמותה (אם כן באיזה גיל ומאיפה, אם לא פרט גם כן):',
                            profileData['Adopted']),
                      ]),
                      //------------------------------------------------------------
                      const SizedBox(height: 20),
                      _buildSectionWithHeading(
                          context, 'בריאות והיסטוריה רפואית:', [
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.health_and_safety,
                            'האם הכלב שלך בריא? יש מצב רפואי או צרכים מיוחדים?',
                            profileData['Question1']),
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.vaccines,
                            'האם הכלב שלך מעודכן בחיסונים?',
                            profileData['Question2']),
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.no_food,
                            'יש אלרגיות או הגבלות תזונתיות?',
                            profileData['Question3']),
                      ]),
                      //------------------------------------------------------------
                      const SizedBox(height: 20),
                      _buildSectionWithHeading(context, 'היסטוריה התנהגותית:', [
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.psychology,
                            'האם הכלב שלך עבר אילוף קודם? אם כן, אנא ספק פרטים',
                            profileData['Question4']),
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.people,
                            'איך הכלב שלך מגיב בדרך כלל לאנשים חדשים או לבעלי חיים אחרים',
                            profileData['Question5']),
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.noise_control_off,
                            'האם הכלב שלך נוח בסביבות שונות (למשל, מקומות צפופים, רעשים חזקים)',
                            profileData['Question6']),
                      ]),
                      //------------------------------------------------------------
                      const SizedBox(height: 20),
                      _buildSectionWithHeading(context, 'רמת הכשרה נוכחית:', [
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.assessment,
                            'אילו פקודות הכלב שלך כבר יודע?',
                            profileData['Question7']),
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.thumb_up,
                            'עד כמה הכלב שלך מגיב לפקודות?',
                            profileData['Question8']),
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.swap_horiz,
                            'האם יש התנהגויות ספציפיות שהיית רוצה לחזק או לשנות?',
                            profileData['Question9']),
                      ]),
                      //------------------------------------------------------------
                      const SizedBox(height: 20),
                      _buildSectionWithHeading(context, 'בעיות התנהגות:', [
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.warning,
                            'האם הכלב שלך מפגין התנהגות תוקפנית כלשהי? אם כן, נא לתאר',
                            profileData['Question10']),
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.sentiment_very_dissatisfied,
                            'האם הכלב שלך נוטה לחרדה או פחד במצבים מסויימים?',
                            profileData['Question11']),
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.flag,
                            'האם יש טריגרים ספציפיים לבעיות ההתנהגות של הכלב שלך?',
                            profileData['Question12']),
                      ]),
                      //------------------------------------------------------------
                      const SizedBox(height: 20),
                      _buildSectionWithHeading(context, 'יעדי אימון:', [
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.flag,
                            'מהן המטרות העיקריות שלך לאילוף הכלב שלך?',
                            profileData['Question13']),
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.change_circle,
                            'האם יש התנהגויות ספציפיות שאתה רוצה לטפל בהן (למשל, משיכת רצועה, נביחות מוגזמות)',
                            profileData['Question14']),
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.verified_user,
                            'האם יש לך מטרות אילוף לטווח ארוך עבור הכלב שלך?',
                            profileData['Question15']),
                      ]),
                      //------------------------------------------------------------
                      const SizedBox(height: 20),
                      _buildSectionWithHeading(context, 'שגרה יומית:', [
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.schedule,
                            'תאר את שגרת היומיום של הכלב שלך, כולל לוח הזמנים של האכלה, פעילות גופנית ושינה',
                            profileData['Question16']),
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.timer,
                            'כמה זמן אתה יכול להקדיש לתרגילי אימון יומיים?',
                            profileData['Question17']),
                      ]),
                      //------------------------------------------------------------
                      const SizedBox(height: 20),
                      _buildSectionWithHeading(context, 'סוציאליזציה:', [
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.group_add,
                            'באיזו תדירות הכלב שלך נחשף לכלבים או לאנשים אחרים?',
                            profileData['Question18']),
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.group_work,
                            'האם הכלב שלך משתתף בגני כלבים או באירועים חברתיים לכלבים?',
                            profileData['Question19']),
                      ]),
                      //------------------------------------------------------------
                      const SizedBox(height: 20),
                      _buildSectionWithHeading(context, 'סביבת אימון:', [
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.place,
                            'היכן אתה בדרך כלל מאלף את הכלב שלך? (למשל, בית, פארקים ציבוריים)',
                            profileData['Question20']),
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.landscape,
                            'האם יש אתגרים ספציפיים בסביבת האימון שלך?',
                            profileData['Question21']),
                      ]),
                      //------------------------------------------------------------
                      const SizedBox(height: 20),
                      _buildSectionWithHeading(context, 'מניעים ותגמולים:', [
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.star_border,
                            'מה מניע את הכלב שלך? (למשל, פינוקים, צעצועים, שבחים מילוליים)',
                            profileData['Question22']),
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.card_giftcard,
                            'האם יש תגמולים ספציפיים שהכלב שלך מגיב אליהם בצורה יוצאת דופן?',
                            profileData['Question23']),
                      ]),
                      //------------------------------------------------------------
                      const SizedBox(height: 20),
                      _buildSectionWithHeading(context, 'העדפות אימון:', [
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.group,
                            'האם אתה מעוניין באימונים קבוצתיים או במפגשים אחד על אחד?',
                            profileData['Question24']),
                        _buildQuestionAnswerWithIcon(
                            context,
                            Icons.settings,
                            'האם יש לך העדפות לגבי שיטות או טכניקות אימון?',
                            profileData['Question25']),
                      ]),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

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

Widget _buildMediaWidget(dynamic media) {
  if (media['type'] == 'image') {
    return Image.network(
      media['url'],
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder:
          (BuildContext context, Object exception, StackTrace? stackTrace) {
        print('Failed to load image: $exception');
        return const Text('Failed to load image');
      },
    );
  } else if (media['type'] == 'video') {
    return SizedBox(
      width: 100,
      height: 100,
      child: VideoPlayerWidget(
        url: media['url'],
      ),
    );
  }
  return const SizedBox.shrink();
}
