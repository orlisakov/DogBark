// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, avoid_print, use_build_context_synchronously, library_private_types_in_public_api, prefer_interpolation_to_compose_strings
import 'package:http_parser/http_parser.dart' as http_parser;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logging/logging.dart';
import 'package:pinalprojectbark/design.dart';
import 'package:pinalprojectbark/pages/config.dart';
import 'package:pinalprojectbark/pages/owner/profilePageOwner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

final Logger _logger = Logger('MultiStepFormOwnerPage');

class MultiStepFormOwner extends StatefulWidget {
  final token, dogData;
  const MultiStepFormOwner(
      {@required this.token, required this.dogData, super.key});

  @override
  State<MultiStepFormOwner> createState() => _MultiStepFormOwnerState();
}

class _MultiStepFormOwnerState extends State<MultiStepFormOwner> {
  final TextEditingController _DogNameController = TextEditingController();
  final TextEditingController _RaceController = TextEditingController();
  final TextEditingController _WeightController = TextEditingController();
  final TextEditingController _AdoptedController = TextEditingController();
  final TextEditingController _Question1Controller = TextEditingController();
  final TextEditingController _Question2Controller = TextEditingController();
  final TextEditingController _Question3Controller = TextEditingController();
  final TextEditingController _Question4Controller = TextEditingController();
  final TextEditingController _Question5Controller = TextEditingController();
  final TextEditingController _Question6Controller = TextEditingController();
  final TextEditingController _Question7Controller = TextEditingController();
  final TextEditingController _Question8Controller = TextEditingController();
  final TextEditingController _Question9Controller = TextEditingController();
  final TextEditingController _Question10Controller = TextEditingController();
  final TextEditingController _Question11Controller = TextEditingController();
  final TextEditingController _Question12Controller = TextEditingController();
  final TextEditingController _Question13Controller = TextEditingController();
  final TextEditingController _Question14Controller = TextEditingController();
  final TextEditingController _Question15Controller = TextEditingController();
  final TextEditingController _Question16Controller = TextEditingController();
  final TextEditingController _Question17Controller = TextEditingController();
  final TextEditingController _Question18Controller = TextEditingController();
  final TextEditingController _Question19Controller = TextEditingController();
  final TextEditingController _Question20Controller = TextEditingController();
  final TextEditingController _Question21Controller = TextEditingController();
  final TextEditingController _Question22Controller = TextEditingController();
  final TextEditingController _Question23Controller = TextEditingController();
  final TextEditingController _Question24Controller = TextEditingController();
  final TextEditingController _Question25Controller = TextEditingController();

  late String userId;
  String dogId = '';
  int currentStep = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late SharedPreferences prefs;
  final ImagePicker picker = ImagePicker();
  String _mediaType = 'image';
  List<Map<String, dynamic>> mediaFiles = [];

  @override
  void initState() {
    super.initState();
    initSharedPref();

    if (widget.token != null) {
      Map<String, dynamic>? jwtDecodedToken = JwtDecoder.decode(widget.token);
      if (jwtDecodedToken.isNotEmpty && jwtDecodedToken.containsKey('_id')) {
        userId = jwtDecodedToken['_id'];
      } else {
        _logger.severe("JWT token decoding failed or '_id' not found.");
      }
    } else {
      _logger.severe("Token is null.");
    }

    if (widget.dogData != null && widget.dogData is Map) {
      dogId = widget.dogData['_id'] ?? '';
      if (dogId.isNotEmpty) {
        fetchAndSetProfileData(dogId);
      } else {
        _logger.info("No dog ID provided. Assuming new profile creation.");
      }
    } else {
      _logger.severe("Dog data is null or not a Map.");
    }
  }

  Future<void> fetchAndSetProfileData(String dogId) async {
    try {
      final url = Uri.parse('$getDogProfileById/$dogId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Fetched Data: $data");

        setState(() {
          _DogNameController.text = data['DogName'] ?? '';
          _RaceController.text = data['Race'] ?? '';
          _WeightController.text = data['Weight'] ?? '';
          _AdoptedController.text = data['Adopted'] ?? '';
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

          // Handle the dog image if it exists
          if (data['dogImage'] != null) {
            mediaFiles.add({
              'type': 'image',
              'url': 'http://192.168.70.1:3000/' + data['dogImage'],
            });
          } else {
            print("No existing dog image found.");
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

  Future<void> _pickMedia() async {
    try {
      final pickedFile = _mediaType == 'image'
          ? await picker.pickImage(source: ImageSource.gallery)
          : await picker.pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            mediaFiles.add({
              'type': _mediaType,
              'data': bytes,
              'path': pickedFile.path,
            });
          });
        } else {
          setState(() {
            mediaFiles.add({
              'type': _mediaType,
              'file': File(pickedFile.path),
              'path': pickedFile.path,
            });
          });
        }
      }
    } catch (e) {
      // Handle any errors
    }
  }

  Future<void> addUserDogProfile() async {
    if (_DogNameController.text.isNotEmpty && _RaceController.text.isNotEmpty) {
      var request = http.MultipartRequest(
        dogId.isEmpty ? 'POST' : 'PUT',
        Uri.parse(dogId.isEmpty ? addDogProfile : '$updateDogProfile/$dogId'),
      );
      // Adding text fields
      request.fields['userId'] = userId;
      request.fields['DogName'] = _DogNameController.text;
      request.fields['Race'] = _RaceController.text;
      request.fields['Weight'] = _WeightController.text;
      request.fields['Adopted'] = _AdoptedController.text;
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

      // Adding media files
      for (var media in mediaFiles) {
        if (media['type'] == 'image') {
          String relativePath = 'uploads/${media['path'].split('\\').last}';
          request.files.add(await http.MultipartFile.fromPath(
            'media',
            media['path'],
            filename: relativePath,
            contentType: http_parser.MediaType('image', 'jpeg'),
          ));
        } else if (media['type'] == 'video') {
          String relativePath = 'uploads/${media['path'].split('\\').last}';
          request.files.add(await http.MultipartFile.fromPath(
            'media',
            media['path'],
            filename: relativePath,
            contentType: http_parser.MediaType('video', 'mp4'),
          ));
        }
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
                builder: (context) => ProfilePageOwner(token: widget.token)),
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

  Widget _buildMediaWidget(dynamic media) {
    if (media['type'] == 'image') {
      if (media['file'] != null) {
        return Image.file(
          media['file'],
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder:
              (BuildContext context, Object exception, StackTrace? stackTrace) {
            print('Failed to load image: $exception');
            return const Text('Failed to load image');
          },
        );
      } else if (media['url'] != null) {
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
      }
    } else if (media['type'] == 'video') {
      return SizedBox(
        width: 100,
        height: 100,
        child: VideoPlayerWidget(
          url: media['url'] ?? media['path'],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'פרופיל כלב:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Rubik',
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
                  addUserDogProfile();
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
                      onPressed: () {
                        _logger
                            .warning("Button pressed, isLastStep: $isLastStep");
                        if (details.onStepContinue != null) {
                          details.onStepContinue!();
                        } else {
                          _logger.warning("onStepContinue is null");
                        }
                      },
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
    return [
      Step(
        title: const Text(
          'פרטי כלב',
          style: TextStyle(
            fontFamily: 'Rubik',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _mediaType = 'image';
                        });
                        _pickMedia();
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('הוסף תמונה'),
                    ),
                    const SizedBox(width: 16.0),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _mediaType = 'video';
                        });
                        _pickMedia();
                      },
                      icon: const Icon(Icons.video_call),
                      label: const Text('הוסף וידאו'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  children: mediaFiles.map((file) {
                    return Stack(
                      children: [
                        _buildMediaWidget(file),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                mediaFiles.remove(file);
                              });
                            },
                            child: const Icon(Icons.remove_circle,
                                color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                _buildFormField('שם כלב:', _DogNameController),
                const SizedBox(height: 10),
                _buildFormField('גזע:', _RaceController),
                const SizedBox(height: 10),
                _buildFormField('משקל:', _WeightController),
                const SizedBox(height: 10),
                _buildFormField('מאומץ:', _AdoptedController),
              ],
            ),
          ),
        ),
        isActive: currentStep >= 0,
        state: currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text(
          'בריאות והיסטוריה רפואית:',
          style: TextStyle(
            fontFamily: 'Rubik',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                _buildFormField(
                  'האם הכלב שלך בריא? יש מצב רפואי או צרכים מיוחדים?',
                  _Question1Controller,
                ),
                const SizedBox(height: 10),
                _buildFormField(
                  'האם הכלב שלך מעודכן בחיסונים?',
                  _Question2Controller,
                ),
                const SizedBox(height: 10),
                _buildFormField(
                  'יש אלרגיות או הגבלות תזונתיות?',
                  _Question3Controller,
                ),
              ],
            ),
          ),
        ),
        isActive: currentStep >= 1,
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text(
          'היסטוריה התנהגותית:',
          style: TextStyle(
            fontFamily: 'Rubik',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                _buildFormField(
                  'האם הכלב שלך עבר אילוף קודם? אם כן, אנא ספק פרטים',
                  _Question4Controller,
                ),
                const SizedBox(height: 10),
                _buildFormField(
                  'איך הכלב שלך מגיב בדרך כלל לאנשים חדשים או לבעלי חיים אחרים',
                  _Question5Controller,
                ),
                const SizedBox(height: 10),
                _buildFormField(
                  'האם הכלב שלך נוח בסביבות שונות (למשל, מקומות צפופים, רעשים חזקים)',
                  _Question6Controller,
                ),
              ],
            ),
          ),
        ),
        isActive: currentStep >= 2,
        state: currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text(
          'רמת הכשרה נוכחית:',
          style: TextStyle(
            fontFamily: 'Rubik',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                _buildFormField(
                  'אילו פקודות הכלב שלך כבר יודע?',
                  _Question7Controller,
                ),
                const SizedBox(height: 10),
                _buildFormField(
                  'עד כמה הכלב שלך מגיב לפקודות?',
                  _Question8Controller,
                ),
                const SizedBox(height: 10),
                _buildFormField(
                  'האם יש התנהגויות ספציפיות שהיית רוצה לחזק או לשנות?',
                  _Question9Controller,
                ),
              ],
            ),
          ),
        ),
        isActive: currentStep >= 3,
        state: currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text(
          'בעיות התנהגות:',
          style: TextStyle(
            fontFamily: 'Rubik',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                _buildFormField(
                  'האם הכלב שלך מפגין התנהגות תוקפנית כלשהי? אם כן, נא לתאר',
                  _Question10Controller,
                ),
                const SizedBox(height: 10),
                _buildFormField(
                  'האם הכלב שלך נוטה לחרדה או פחד במצבים מסויימים?',
                  _Question11Controller,
                ),
                const SizedBox(height: 10),
                _buildFormField(
                  'האם יש טריגרים ספציפיים לבעיות ההתנהגות של הכלב שלך?',
                  _Question12Controller,
                ),
              ],
            ),
          ),
        ),
        isActive: currentStep >= 4,
        state: currentStep > 4 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text(
          'יעדי אימון:',
          style: TextStyle(
            fontFamily: 'Rubik',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                _buildFormField(
                  'מהן המטרות העיקריות שלך לאילוף הכלב שלך?',
                  _Question13Controller,
                ),
                const SizedBox(height: 10),
                _buildFormField(
                  'האם יש התנהגויות ספציפיות שאתה רוצה לטפל בהן (למשל, משיכת רצועה, נביחות מוגזמות)',
                  _Question14Controller,
                ),
                const SizedBox(height: 10),
                _buildFormField(
                  'האם יש לך מטרות אילוף לטווח ארוך עבור הכלב שלך?',
                  _Question15Controller,
                ),
              ],
            ),
          ),
        ),
        isActive: currentStep >= 5,
        state: currentStep > 5 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text(
          'שגרה יומית:',
          style: TextStyle(
            fontFamily: 'Rubik',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                _buildFormField(
                  'תאר את שגרת היומיום של הכלב שלך, כולל לוח הזמנים של האכלה, פעילות גופנית ושינה',
                  _Question16Controller,
                ),
                const SizedBox(height: 10),
                _buildFormField(
                  'כמה זמן אתה יכול להקדיש לתרגילי אימון יומיים?',
                  _Question17Controller,
                ),
              ],
            ),
          ),
        ),
        isActive: currentStep >= 6,
        state: currentStep > 6 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text(
          'סוציאליזציה:',
          style: TextStyle(
            fontFamily: 'Rubik',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                _buildFormField(
                  'באיזו תדירות הכלב שלך נחשף לכלבים או לאנשים אחרים?',
                  _Question18Controller,
                ),
                const SizedBox(height: 10),
                _buildFormField(
                  'האם הכלב שלך משתתף בגני כלבים או באירועים חברתיים לכלבים?',
                  _Question19Controller,
                ),
              ],
            ),
          ),
        ),
        isActive: currentStep >= 7,
        state: currentStep > 7 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text(
          'סביבת אימון:',
          style: TextStyle(
            fontFamily: 'Rubik',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                _buildFormField(
                  'היכן אתה בדרך כלל מאלף את הכלב שלך? (למשל, בית, פארקים ציבוריים)',
                  _Question20Controller,
                ),
                const SizedBox(height: 10),
                _buildFormField(
                  'האם יש אתגרים ספציפיים בסביבת האימון שלך?',
                  _Question21Controller,
                ),
              ],
            ),
          ),
        ),
        isActive: currentStep >= 8,
        state: currentStep > 8 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text(
          'מניעים ותגמולים:',
          style: TextStyle(
            fontFamily: 'Rubik',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                _buildFormField(
                  'מה מניע את הכלב שלך? (למשל, פינוקים, צעצועים, שבחים מילוליים)',
                  _Question22Controller,
                ),
                const SizedBox(height: 10),
                _buildFormField(
                  'האם יש תגמולים ספציפיים שהכלב שלך מגיב אליהם בצורה יוצאת דופן?',
                  _Question23Controller,
                ),
              ],
            ),
          ),
        ),
        isActive: currentStep >= 9,
        state: currentStep > 9 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text(
          'העדפות אימון:',
          style: TextStyle(
            fontFamily: 'Rubik',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                _buildFormField(
                  'האם אתה מעוניין באימונים קבוצתיים או במפגשים אחד על אחד?',
                  _Question24Controller,
                ),
                const SizedBox(height: 10),
                _buildFormField(
                  'האם יש לך העדפות לגבי שיטות או טכניקות אימון?',
                  _Question25Controller,
                ),
              ],
            ),
          ),
        ),
        isActive: currentStep >= 10,
        state: currentStep > 10 ? StepState.complete : StepState.indexed,
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
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: AppColors.backgroundColor,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'נא תן תשובה מלאה לשאלה';
            }
            return null;
          },
        ),
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
