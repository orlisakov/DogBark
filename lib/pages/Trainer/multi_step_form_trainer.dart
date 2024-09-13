// ignore_for_file: unused_element, non_constant_identifier_names, use_build_context_synchronously, prefer_typing_uninitialized_variables
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logging/logging.dart';
import 'package:pinalprojectbark/design.dart';
import 'package:pinalprojectbark/pages/Trainer/profilePageTrainer.dart';
import 'package:pinalprojectbark/pages/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart' as http_parser;

final Logger _logger = Logger('MultiStepFormTrainerPage');

class MultiStepFormTrainer extends StatefulWidget {
  final String token;
  final Map<String, dynamic> profileData;
  const MultiStepFormTrainer(
      {required this.token, required this.profileData, super.key});

  @override
  State<MultiStepFormTrainer> createState() => _MultiStepFormTrainerState();
}

class _MultiStepFormTrainerState extends State<MultiStepFormTrainer> {
  final _FirstNameController = TextEditingController();
  final _LastNameController = TextEditingController();
  final _PhoneNumController = TextEditingController();
  final _AreaController = TextEditingController();
  final _Question1Controller = TextEditingController();
  final _Question2Controller = TextEditingController();
  final _Question3Controller = TextEditingController();
  final _Question4Controller = TextEditingController();
  final _Question5Controller = TextEditingController();
  final _Question6Controller = TextEditingController();
  final _Question7Controller = TextEditingController();
  final _Question8Controller = TextEditingController();
  final _Question9Controller = TextEditingController();
  final _Question10Controller = TextEditingController();
  final _Question11Controller = TextEditingController();
  final _Question12Controller = TextEditingController();
  final _Question13Controller = TextEditingController();
  final _Question14Controller = TextEditingController();
  final _Question15Controller = TextEditingController();
  final _Question16Controller = TextEditingController();
  final _Question17Controller = TextEditingController();
  final _Question18Controller = TextEditingController();
  final _Question19Controller = TextEditingController();
  final _Question20Controller = TextEditingController();
  final _Question21Controller = TextEditingController();
  final _Question22Controller = TextEditingController();
  final _Question23Controller = TextEditingController();
  final _Question24Controller = TextEditingController();
  final _Question25Controller = TextEditingController();
  final _Question26Controller = TextEditingController();
  final _Question27Controller = TextEditingController();
  final _Question28Controller = TextEditingController();
  final _Question29Controller = TextEditingController();

  late String userId, profileId;
  int currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  late SharedPreferences prefs;

  final ImagePicker picker = ImagePicker();
  File? _trainerImage;
  List<Map<String, dynamic>> certificates = [];

  @override
  void initState() {
    super.initState();
    initSharedPref();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'] ?? '';
    profileId = widget.profileData['_id'] ?? '';

    if (profileId.isNotEmpty) {
      fetchAndSetProfileData(profileId);
      debugPrint("Fetched data: $profileId");
    }
  }

  Future<void> fetchAndSetProfileData(String profileId) async {
    try {
      final url = Uri.parse('$getTrainerProfileById/$profileId');
      final response = await http.get(url);
      debugPrint("Fetching data from URL: $url");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Fetched data: $data");

        setState(() {
          _FirstNameController.text = data['FirstName'] ?? '';
          _LastNameController.text = data['LastName'] ?? '';
          _PhoneNumController.text = data['PhoneNum'] ?? '';
          _AreaController.text = data['Area'] ?? '';
          _Question1Controller.text = data['Question1'] ?? '';
          _Question2Controller.text = data['Question2'] ?? '';
          _Question3Controller.text = data['Question3'] ?? '';
          _Question4Controller.text = data['Question4'] ?? '';
          _Question5Controller.text = data['Question5'] ?? '';
          _Question6Controller.text = data['Question6'] ?? '';
          _Question7Controller.text = data['Question7'] ?? '';
          _Question8Controller.text = data['Question8'] ?? '';
          _Question9Controller.text = data['Question9'] ?? '';
          _Question10Controller.text = data['Question10'] ?? '';
          _Question11Controller.text = data['Question11'] ?? '';
          _Question12Controller.text = data['Question12'] ?? '';
          _Question13Controller.text = data['Question13'] ?? '';
          _Question14Controller.text = data['Question14'] ?? '';
          _Question15Controller.text = data['Question15'] ?? '';
          _Question16Controller.text = data['Question16'] ?? '';
          _Question17Controller.text = data['Question17'] ?? '';
          _Question18Controller.text = data['Question18'] ?? '';
          _Question19Controller.text = data['Question19'] ?? '';
          _Question20Controller.text = data['Question20'] ?? '';
          _Question21Controller.text = data['Question21'] ?? '';
          _Question22Controller.text = data['Question22'] ?? '';
          _Question23Controller.text = data['Question23'] ?? '';
          _Question24Controller.text = data['Question24'] ?? '';
          _Question25Controller.text = data['Question25'] ?? '';
          _Question26Controller.text = data['Question26'] ?? '';
          _Question27Controller.text = data['Question27'] ?? '';
          _Question28Controller.text = data['Question28'] ?? '';
          _Question29Controller.text = data['Question29'] ?? '';

          // Handle trainer image if it exists
          if (data['profilePicture'] != null) {
            _trainerImage = File(data['profilePicture']);
          }

          // Handle certificates if they exist
          if (data['certificates'] != null) {
            certificates = (data['certificates'] as List).map((certPath) {
              return {'path': certPath, 'name': certPath.split('/').last};
            }).toList();
          }
        });
      } else {
        debugPrint("Failed to fetch dog data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching dog data: $e");
    }
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _pickTrainerImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _trainerImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _logger.severe("Error picking image: $e");
    }
  }

  Future<void> _pickCertificate() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          certificates.add({
            'path': pickedFile.path,
            'name': pickedFile.name,
          });
        });
      }
    } catch (e) {
      _logger.severe("Error picking certificate: $e");
    }
  }

  void addTrainerProfile() async {
    if (_FirstNameController.text.isNotEmpty &&
        _LastNameController.text.isNotEmpty) {
      var request = http.MultipartRequest(
        profileId.isEmpty ? 'POST' : 'PUT',
        Uri.parse(profileId.isEmpty
            ? aaddTrainerProfile
            : '$updateTrainerProfile/$profileId'),
      );

      request.fields['userId'] = userId;
      request.fields['FirstName'] = _FirstNameController.text;
      request.fields['LastName'] = _LastNameController.text;
      request.fields['PhoneNum'] = _PhoneNumController.text;
      request.fields['Area'] = _AreaController.text;
      request.fields['Question1'] = _Question1Controller.text;
      request.fields['Question2'] = _Question2Controller.text;
      request.fields['Question3'] = _Question3Controller.text;
      request.fields['Question4'] = _Question4Controller.text;
      request.fields['Question5'] = _Question5Controller.text;
      request.fields['Question6'] = _Question6Controller.text;
      request.fields['Question7'] = _Question7Controller.text;
      request.fields['Question8'] = _Question8Controller.text;
      request.fields['Question9'] = _Question9Controller.text;
      request.fields['Question10'] = _Question10Controller.text;
      request.fields['Question11'] = _Question11Controller.text;
      request.fields['Question12'] = _Question12Controller.text;
      request.fields['Question13'] = _Question13Controller.text;
      request.fields['Question14'] = _Question14Controller.text;
      request.fields['Question15'] = _Question15Controller.text;
      request.fields['Question16'] = _Question16Controller.text;
      request.fields['Question17'] = _Question17Controller.text;
      request.fields['Question18'] = _Question18Controller.text;
      request.fields['Question19'] = _Question19Controller.text;
      request.fields['Question20'] = _Question20Controller.text;
      request.fields['Question21'] = _Question21Controller.text;
      request.fields['Question22'] = _Question22Controller.text;
      request.fields['Question23'] = _Question23Controller.text;
      request.fields['Question24'] = _Question24Controller.text;
      request.fields['Question25'] = _Question25Controller.text;
      request.fields['Question26'] = _Question26Controller.text;
      request.fields['Question27'] = _Question27Controller.text;
      request.fields['Question28'] = _Question28Controller.text;
      request.fields['Question29'] = _Question29Controller.text;

      // Adding trainer image
      if (_trainerImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profilePicture',
          _trainerImage!.path,
          contentType: http_parser.MediaType('image', 'jpeg'),
        ));
      }

      // Adding certificates
      for (var cert in certificates) {
        request.files.add(await http.MultipartFile.fromPath(
          'certificates',
          cert['path'],
          contentType: http_parser.MediaType('image', 'jpeg'),
        ));
      }

      // Sending the request
      request.headers['Authorization'] = 'Bearer ${widget.token}';
      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);
        if (jsonResponse['status']) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => ProfilePageTrainer(token: widget.token)),
            (Route<dynamic> route) => false,
          );
        } else {
          _logger.warning("Something went wrong.");
        }
      } else {
        _logger.severe(
            "Failed with status: ${response.statusCode} and body: ${await response.stream.bytesToString()}");
      }
    }
  }

  //---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'טופס פרופיל מאלף',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Rubik',
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
        ),
        body: Form(
          key: _formKey,
          child: Stepper(
            type: StepperType.vertical,
            steps: getSteps(),
            currentStep: currentStep,
            onStepContinue: () {
              final isLastStep = currentStep == getSteps().length - 1;
              if (isLastStep) {
                if (_formKey.currentState!.validate()) {
                  addTrainerProfile();
                }
              } else {
                setState(() => currentStep += 1);
              }
            },
            onStepCancel: currentStep == 0
                ? null
                : () => setState(() => currentStep -= 1),
            controlsBuilder: (BuildContext context, ControlsDetails details) {
              final isLastStep = currentStep == getSteps().length - 1;
              return Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: AppColors.secondaryColor,
                      ),
                      child: Text(
                        isLastStep ? 'צור פרופיל' : 'המשך',
                        style: const TextStyle(
                          fontFamily: 'Alef',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (currentStep != 0)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: details.onStepCancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: const Text(
                          'חזור',
                          style: TextStyle(
                            fontFamily: 'Alef',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Step> getSteps() {
    return <Step>[
      // --------------------------- 1 -----------------------------
      Step(
        title: const Text(
          'מידע בסיסי:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
          ),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // --------------------------------------------------------
              ElevatedButton.icon(
                onPressed: _pickTrainerImage,
                icon: const Icon(Icons.image),
                label: const Text('הוסף תמונת מאלף'),
              ),
              if (_trainerImage != null)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: AppColors.accentColor,
                      width: 2.0,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.file(
                      _trainerImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _buildFormField('שם פרטי', _FirstNameController),
              _buildFormField('שם משפחה', _LastNameController),
              _buildFormField('מספר טלפון', _PhoneNumController),
              _buildFormField('איזור עבודה', _AreaController),
              _buildFormField(
                  'הסמכות מקצועיות או השתייכות:', _Question1Controller),
            ],
          ),
        ),
      ),
      // --------------------------- 2 -----------------------------
      Step(
        title: const Text(
          'ניסיון ומומחיות:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
          ),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // --------------------------------------------------------
              _buildFormField(
                  'כמה שנות ניסיון יש לך כמאלף כלבים?', _Question2Controller),
              _buildFormField(
                  'עם אילו גזעים יש לך ניסיון בעבודה?', _Question3Controller),
              _buildFormField(
                  'האם אתה מתמחה בטכניקות או מתודולוגיות אימון ספציפיות?',
                  _Question4Controller),
            ],
          ),
        ),
      ),
      // --------------------------- 3 -----------------------------
      Step(
        title: const Text(
          'פילוסופיית האימון:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
          ),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // --------------------------------------------------------
              _buildFormField(
                  'תאר את פילוסופיית האימון והגישה שלך.', _Question5Controller),
              _buildFormField(
                  'האם אתה נוטה יותר לחיזוק חיובי, אימון קליקים או שיטות אחרות?',
                  _Question6Controller),
            ],
          ),
        ),
      ),
      // --------------------------- 4 -----------------------------
      Step(
        title: const Text(
          'שירותים המוצעים:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
          ),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // --------------------------------------------------------
              _buildFormField(
                  'ציין את סוגי שירותי האימון שאתה מציע (למשל, צייתנות בסיסית, שינוי התנהגות, אימון זריזות).',
                  _Question7Controller),
              _buildFormField(
                  'האם אתה זמין לשיעורים קבוצתיים, למפגשים פרטיים או לשניהם?',
                  _Question8Controller),
            ],
          ),
        ),
      ),
      // --------------------------- 5 -----------------------------
      Step(
        title: const Text(
          'סיפורי הצלחה:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
          ),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // --------------------------------------------------------
              _buildFormField(
                  'שתף כמה סיפורי הצלחה או המלצות מלקוחות קודמים (אם רלוונטי).',
                  _Question9Controller),
              _buildFormField(
                  'הדגש את כל ההישגים הבולטים בקריירת אילוף הכלבים שלך.',
                  _Question10Controller),
            ],
          ),
        ),
      ),

      // --------------------------- 6 -----------------------------
      Step(
        title: const Text(
          'זמינות:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
          ),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // --------------------------------------------------------
              _buildFormField(
                  'ציין את זמינותך לאימונים.', _Question11Controller),
              _buildFormField('האם אתה מוכן לנסוע למקומות של לקוחות להדרכות?',
                  _Question12Controller),
            ],
          ),
        ),
      ),
      // --------------------------- 7 -----------------------------
      Step(
        title: const Text(
          'מיקום ההדרכה:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
          ),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // --------------------------------------------------------
              _buildFormField(
                  'היכן אתה בדרך כלל עורך אימונים? (לדוגמה, במתקן שלך, בבית הלקוח, בגנים ציבוריים)',
                  _Question13Controller),
              _buildFormField('האם יש לך גישה למתקן אימונים או לציוד ספציפי?',
                  _Question14Controller),
            ],
          ),
        ),
      ),
      // --------------------------- 8 -----------------------------
      Step(
        title: const Text(
          'כלי הדרכה:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
          ),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // --------------------------------------------------------
              _buildFormField('באילו כלים או ציוד אתה משתמש בדרך כלל באימונים?',
                  _Question15Controller),
              _buildFormField('האם יש כלים שאתה מעדיף לא להשתמש בהם?',
                  _Question16Controller),
            ],
          ),
        ),
      ),
      // --------------------------- 9 -----------------------------
      Step(
        title: const Text(
          ' דינמיקה קבוצתית:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
          ),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // --------------------------------------------------------
              _buildFormField(
                  'אם ישים, תאר את הגישה שלך לניהול אימונים קבוצתיים.',
                  _Question17Controller),
              _buildFormField(
                  'איך מטפלים בכלבים בעלי מזג משתנה במסגרת קבוצתית?',
                  _Question18Controller),
            ],
          ),
        ),
      ),
      // --------------------------- 10 -----------------------------
      Step(
        title: const Text(
          'השכלה מתמשכת:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
          ),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // --------------------------------------------------------
              _buildFormField(
                  'איך אתה נשאר מעודכן בטכניקות ובמחקר העדכניים של אילוף כלבים?',
                  _Question19Controller),
              _buildFormField(
                  'האם השתתפת לאחרונה בסדנאות, סמינרים או כנסים הקשורים לאילוף כלבים?',
                  _Question20Controller),
            ],
          ),
        ),
      ),
      // --------------------------- 11 -----------------------------
      Step(
        title: const Text(
          'תקשורת לקוח:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
          ),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // --------------------------------------------------------
              _buildFormField('איך אתה מתקשר עם לקוחות בין הפגישות?',
                  _Question21Controller),
              _buildFormField(
                  'האם אתה פתוח לקבל משוב מלקוחות?', _Question22Controller),
            ],
          ),
        ),
      ),
      // --------------------------- 12 -----------------------------
      Step(
        title: const Text(
          'עלויות ומדיניות:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
          ),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // --------------------------------------------------------
              _buildFormField('ציין את העמלות שלך וכל אפשרויות החבילה הזמינות.',
                  _Question23Controller),
              _buildFormField('תאר את מדיניות הביטול או תזמון מחדש שלך.',
                  _Question24Controller),
            ],
          ),
        ),
      ),
      // --------------------------- 13 -----------------------------
      Step(
        title: const Text(
          'הפניות:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
          ),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // --------------------------------------------------------
              _buildFormField(
                  'האם אתה יכול לספק הפניות מלקוחות קודמים או עמיתים בתעשייה?',
                  _Question25Controller),
            ],
          ),
        ),
      ),
      // --------------------------- 14 -----------------------------
      Step(
        title: const Text(
          'ביטוח ואחריות:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
          ),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // --------------------------------------------------------
              _buildFormField('יש לך ביטוח אחריות?', _Question26Controller),
              _buildFormField(
                  'האם יש אחריות או אמצעי בטיחות ספציפיים שלקוחות צריכים להיות מודעים אליהם?',
                  _Question27Controller),
            ],
          ),
        ),
      ),
      // --------------------------- 15 -----------------------------
      Step(
        title: const Text(
          'גישה אישית:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
          ),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // --------------------------------------------------------
              _buildFormField(
                  'מה מייחד אותך כמאלף כלבים?', _Question28Controller),
              _buildFormField('איך יוצרים קרבה גם עם הכלבים וגם עם בעליהם?',
                  _Question29Controller),
            ],
          ),
        ),
      ),
      Step(
        title: const Text(
          'תעודות והסמכות:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
          ),
        ),
        content: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickCertificate,
              icon: const Icon(Icons.image),
              label: const Text('הוסף תעודה או הסמכה'),
            ),
            Wrap(
              spacing: 8.0,
              children: certificates.map((cert) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: AppColors.accentColor,
                          width: 2.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.file(
                          File(cert['path']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            certificates.remove(cert);
                          });
                        },
                        child: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildFormField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Color(0xFF4E342E),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD7CCC8),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: const Color(0xFF8E8D42),
              width: 1.0,
            ),
          ),
          child: TextFormField(
            controller: controller,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFD7CCC8),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontSize: 16,
              color: Colors.black,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'נא למלא $label';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void goToPreviousStep() {
    if (currentStep > 0) {
      setState(() => currentStep -= 1);
    } else {
      Navigator.pop(context);
    }
  }
}
