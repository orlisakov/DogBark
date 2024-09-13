// ignore_for_file: file_names, prefer_typing_uninitialized_variables, avoid_print, library_private_types_in_public_api, unused_element
import 'dart:convert';
import 'dart:io';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pinalprojectbark/design.dart';
import 'package:pinalprojectbark/pages/owner/multi_step_form_owner.dart';
import 'package:video_player/video_player.dart';
import '../config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('ProfilePageOwner');

class ProfilePageOwner extends StatefulWidget {
  final token;
  const ProfilePageOwner({@required this.token, super.key});

  @override
  State<ProfilePageOwner> createState() => _ProfilePageOwnerState();
}

class _ProfilePageOwnerState extends State<ProfilePageOwner> {
  late String userId, userName, email;
  List<dynamic> items = [];
  final ScrollController _scrollController = ScrollController();

  //-----------------------------------------------------
  @override
  void initState() {
    super.initState();
    Map<String, dynamic>? decodedToken = JwtDecoder.decode(widget.token);

    if (decodedToken.isNotEmpty) {
      userId = decodedToken['_id'] ?? '';
      userName = decodedToken['userName'] ?? '';
      email = decodedToken['email'] ?? '';

      if (userId.isNotEmpty) {
        getProfileDogList(userId);
      } else {
        _logger.severe("User ID is empty.");
      }
    } else {
      _logger.severe("Failed to decode token.");
    }
  }

  //-----------------------------------------------------
  // Method to update the dog profile
  void updateDogProfile(final dogData) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MultiStepFormOwner(token: widget.token, dogData: dogData),
      ),
    );
  }

  //-----------------------------------------------------
  void getProfileDogList(userId) async {
    try {
      var response = await http.post(
        Uri.parse(dogProfileList),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] != null) {
        setState(() {
          items = jsonResponse['success'];
        });
      } else {
        _logger.warning("Failed to load dog profiles.");
      }
    } catch (e) {
      _logger.severe("Error fetching dog profiles: $e");
    }
  }

  //----------------------------------------------------------
  void deleteItem(id) async {
    try {
      var response = await http.post(
        Uri.parse(deleteDogProfile),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == true) {
        getProfileDogList(userId);
      } else {
        _logger.warning("Failed to delete dog profile.");
      }
    } catch (e) {
      _logger.severe("Error deleting dog profile: $e");
    }
  }
  //----------------------------------------------------------

  void navigateToAddDogProfile() {
    const dogId = null;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MultiStepFormOwner(token: widget.token, dogData: dogId),
      ),
    );
  }
  //----------------------------------------------------------

  void _scrollToSelectedContent(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context,
          duration: const Duration(milliseconds: 500));
    }
  }

  //----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            "דף פרופיל",
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
        ),
        body: Column(
          children: [
            const SizedBox(height: 50),
            Center(
              child: Text(
                userName,
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 22,
                  color: AppColors.textColor,
                ),
              ),
            ),
            Center(
              child: Text(
                email,
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 18,
                  color: AppColors.textColor,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: items.length,
                itemBuilder: (context, int index) {
                  final GlobalKey expansionTileKey = GlobalKey();
                  return Slidable(
                    key: ValueKey(items[index]['_id'] ?? ''),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          backgroundColor: Colors.pinkAccent,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'מחק',
                          onPressed: (context) =>
                              deleteItem(items[index]['_id'] ?? ''),
                        ),
                      ],
                    ),
                    child: Card(
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: ExpansionTile(
                          key: expansionTileKey,
                          title: _buildQuestionAnswer(context, 'פרטי הכלב',
                              items[index]['DogName'] ?? ''),
                          initiallyExpanded: false,
                          onExpansionChanged: (bool expanded) {
                            if (expanded) {
                              _scrollToSelectedContent(expansionTileKey);
                            }
                          },
                          children: <Widget>[
                            SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    // Profile picture and change button
                                    SizedBox(
                                      width: double.infinity,
                                      child: Column(
                                        children: [
                                          if (items[index]['dogImage'] !=
                                                  null &&
                                              items[index]['dogImage']
                                                  .isNotEmpty)
                                            Wrap(
                                              spacing: 8.0,
                                              children: (items[index]
                                                      ['dogImage'] as List)
                                                  .map((mediaUrl) {
                                                return ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                  child: Image.network(
                                                    'http://192.168.70.1:3000/$mediaUrl',
                                                    width: 150,
                                                    height: 150,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return const Icon(
                                                          Icons.error,
                                                          size: 50,
                                                          color: Colors.red);
                                                    },
                                                  ),
                                                );
                                              }).toList(),
                                            )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () =>
                                          updateDogProfile(items[index]),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        backgroundColor:
                                            AppColors.secondaryColor,
                                      ),
                                      child: const Text(
                                        'עדכן פרופיל',
                                        style: TextStyle(
                                          fontFamily: 'Alef',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),

                                    // Details Section
                                    const SizedBox(height: 10),
                                    const Divider(),
                                    const SizedBox(height: 10),

                                    // --------------------------- 1 -----------------------------
                                    _buildSectionWithHeading(
                                        context,
                                        'מידע בסיסי',
                                        [
                                          _buildQuestionAnswer(
                                              context,
                                              'שם הכלב:',
                                              items[index]['DogName']),
                                          _buildQuestionAnswer(context, 'גזע:',
                                              items[index]['Race']),
                                          _buildQuestionAnswer(context, 'משקל:',
                                              items[index]['Weight']),
                                          _buildQuestionAnswer(
                                              context,
                                              'האם הכלב מאומץ מעמותה (אם כן באיזה גיל ומאיפה, אם לא פרט גם כן):',
                                              items[index]['Adopted']),
                                        ],
                                        Icons.pets),
                                    // --------------------------- 2 -----------------------------
                                    _buildSectionWithHeading(
                                        context,
                                        'בריאות והיסטוריה רפואית:',
                                        [
                                          _buildQuestionAnswer(
                                              context,
                                              'האם הכלב שלך בריא? יש מצב רפואי או צרכים מיוחדים?',
                                              items[index]['Question1']),
                                          _buildQuestionAnswer(
                                              context,
                                              'האם הכלב שלך מעודכן בחיסונים?',
                                              items[index]['Question2']),
                                          _buildQuestionAnswer(
                                              context,
                                              'יש אלרגיות או הגבלות תזונתיות?',
                                              items[index]['Question3']),
                                        ],
                                        Icons.healing),
                                    // --------------------------- 3 -----------------------------
                                    _buildSectionWithHeading(
                                        context,
                                        'היסטוריה התנהגותית:',
                                        [
                                          _buildQuestionAnswer(
                                              context,
                                              'האם הכלב שלך עבר אילוף קודם? אם כן, אנא ספק פרטים',
                                              items[index]['Question4']),
                                          _buildQuestionAnswer(
                                              context,
                                              'איך הכלב שלך מגיב בדרך כלל לאנשים חדשים או לבעלי חיים אחרים',
                                              items[index]['Question5']),
                                          _buildQuestionAnswer(
                                              context,
                                              'האם הכלב שלך נוח בסביבות שונות (למשל, מקומות צפופים, רעשים חזקים)',
                                              items[index]['Question6']),
                                        ],
                                        Icons.psychology),
                                    // --------------------------- 4 -----------------------------
                                    _buildSectionWithHeading(
                                        context,
                                        'רמת הכשרה נוכחית:',
                                        [
                                          _buildQuestionAnswer(
                                              context,
                                              'אילו פקודות הכלב שלך כבר יודע?',
                                              items[index]['Question7']),
                                          _buildQuestionAnswer(
                                              context,
                                              'עד כמה הכלב שלך מגיב לפקודות?',
                                              items[index]['Question8']),
                                          _buildQuestionAnswer(
                                              context,
                                              'האם יש התנהגויות ספציפיות שהיית רוצה לחזק או לשנות?',
                                              items[index]['Question9']),
                                        ],
                                        Icons.school),
                                    // --------------------------- 5 -----------------------------
                                    _buildSectionWithHeading(
                                        context,
                                        'בעיות התנהגות:',
                                        [
                                          _buildQuestionAnswer(
                                              context,
                                              'האם הכלב שלך מפגין התנהגות תוקפנית כלשהי? אם כן, נא לתאר',
                                              items[index]['Question10']),
                                          _buildQuestionAnswer(
                                              context,
                                              'האם הכלב שלך נוטה לחרדה או פחד במצבים מסויימים?',
                                              items[index]['Question11']),
                                          _buildQuestionAnswer(
                                              context,
                                              'האם יש טריגרים ספציפיים לבעיות ההתנהגות של הכלב שלך?',
                                              items[index]['Question12']),
                                        ],
                                        Icons.warning),
                                    // --------------------------- 6 -----------------------------
                                    _buildSectionWithHeading(
                                        context,
                                        'יעדי אימון:',
                                        [
                                          _buildQuestionAnswer(
                                              context,
                                              'מהן המטרות העיקריות שלך לאילוף הכלב שלך?',
                                              items[index]['Question13']),
                                          _buildQuestionAnswer(
                                              context,
                                              'האם יש התנהגויות ספציפיות שאתה רוצה לטפל בהן (למשל, משיכת רצועה, נביחות מוגזמות)',
                                              items[index]['Question14']),
                                          _buildQuestionAnswer(
                                              context,
                                              'האם יש לך מטרות אילוף לטווח ארוך עבור הכלב שלך?',
                                              items[index]['Question15']),
                                        ],
                                        Icons.flag),
                                    // --------------------------- 7 -----------------------------
                                    _buildSectionWithHeading(
                                        context,
                                        'שגרה יומית:',
                                        [
                                          _buildQuestionAnswer(
                                              context,
                                              'תאר את שגרת היומיום של הכלב שלך, כולל לוח הזמנים של האכלה, פעילות גופנית ושינה',
                                              items[index]['Question16']),
                                          _buildQuestionAnswer(
                                              context,
                                              'כמה זמן אתה יכול להקדיש לתרגילי אימון יומיים?',
                                              items[index]['Question17']),
                                        ],
                                        Icons.schedule),
                                    // --------------------------- 8 -----------------------------
                                    _buildSectionWithHeading(
                                        context,
                                        'סוציאליזציה:',
                                        [
                                          _buildQuestionAnswer(
                                              context,
                                              'באיזו תדירות הכלב שלך נחשף לכלבים או לאנשים אחרים?',
                                              items[index]['Question18']),
                                          _buildQuestionAnswer(
                                              context,
                                              'האם הכלב שלך משתתף בגני כלבים או באירועים חברתיים לכלבים?',
                                              items[index]['Question19']),
                                        ],
                                        Icons.group),
                                    // --------------------------- 9 -----------------------------
                                    _buildSectionWithHeading(
                                        context,
                                        'סביבת אימון:',
                                        [
                                          _buildQuestionAnswer(
                                              context,
                                              'היכן אתה בדרך כלל מאלף את הכלב שלך? (למשל, בית, פארקים ציבוריים)',
                                              items[index]['Question20']),
                                          _buildQuestionAnswer(
                                              context,
                                              'האם יש אתגרים ספציפיים בסביבת האימון שלך?',
                                              items[index]['Question21']),
                                        ],
                                        Icons.home_work),
                                    // --------------------------- 10 -----------------------------
                                    _buildSectionWithHeading(
                                        context,
                                        'מניעים ותגמולים:',
                                        [
                                          _buildQuestionAnswer(
                                              context,
                                              'מה מניע את הכלב שלך? (למשל, פינוקים, צעצועים, שבחים מילוליים)',
                                              items[index]['Question22']),
                                          _buildQuestionAnswer(
                                              context,
                                              'האם יש תגמולים ספציפיים שהכלב שלך מגיב אליהם בצורה יוצאת דופן?',
                                              items[index]['Question23']),
                                        ],
                                        Icons.emoji_events),
                                    // --------------------------- 11 -----------------------------
                                    _buildSectionWithHeading(
                                        context,
                                        'העדפות אימון:',
                                        [
                                          _buildQuestionAnswer(
                                              context,
                                              'האם אתה מעוניין באימונים קבוצתיים או במפגשים אחד על אחד?',
                                              items[index]['Question24']),
                                          _buildQuestionAnswer(
                                              context,
                                              'האם יש לך העדפות לגבי שיטות או טכניקות אימון?',
                                              items[index]['Question25']),
                                        ],
                                        Icons.settings),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddDogProfile,
          tooltip: 'Add New Dog Profile',
          icon: const Icon(Icons.add),
          label: const Text('הוסף כלב'),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
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

class VideoPlayerWidget extends StatefulWidget {
  final String? url;
  final File? file;

  const VideoPlayerWidget({Key? key, this.url, this.file}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.url != null) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url!))
        ..initialize().then((_) {
          setState(() {});
          _controller.play();
        });
    } else if (widget.file != null) {
      _controller = VideoPlayerController.file(widget.file!)
        ..initialize().then((_) {
          setState(() {});
          _controller.play();
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
