// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:pinalprojectbark/design.dart';
import 'package:pinalprojectbark/pages/owner/trainerProfileScreen.dart';
import '../config.dart'; // Make sure this path correctly points to your config.dart file

final Logger _logger = Logger('DogTrainerSearchPage');

class DogTrainerSearchPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final token;
  const DogTrainerSearchPage({required this.token, super.key});

  @override
  State<DogTrainerSearchPage> createState() => _DogTrainerSearchPageState();
}

class _DogTrainerSearchPageState extends State<DogTrainerSearchPage> {
  final TextEditingController _areaController = TextEditingController();
  List<dynamic> _searchResults = []; // Holds search results
  List<dynamic> _trainersList = []; // Holds all trainers

  bool _showSearchResults = false;

  //------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    fetchAllTrainers();
  }

  //------------------------------------------------------------------------
  Future<void> fetchAllTrainers() async {
    final Uri uri = Uri.parse(allTrainers);
    // Adjust this with your actual endpoint from config
    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${widget.token}",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _trainersList = data['success'] ?? [];
        //print("fetchAllTrainers: $_trainersList");
      });
    } else {
      _logger.warning('Failed to fetch all trainers: ${response.statusCode}');
    }
  }

//------------------------------------------------------------------------
  Future<void> searchTrainersByAreaa(String area) async {
    final String encodedArea = Uri.encodeComponent(area);
    final Uri uri = Uri.parse('$searchTrainersByArea?area=$encodedArea');

    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${widget.token}",
      },
    );

    //_logger.info('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      // Assuming jsonResponse['success'] is a boolean indicating the presence of data
      // And the actual list of trainers is under a different key, e.g., jsonResponse['trainers']
      if (jsonResponse['success'] == true &&
          jsonResponse.containsKey('trainers') &&
          jsonResponse['trainers'].isNotEmpty) {
        setState(() {
          _searchResults = jsonResponse['trainers'];
          _showSearchResults = true;
          //print("searchTrainersByAreaa: $_searchResults");
        });
      } else {
        setState(() {
          _searchResults = [];
          _showSearchResults = true;
        });
        _logger.info('${area.trim()} not found in the system');
      }
    } else {
      _logger.warning(
          'Failed to fetch trainers. Status code: ${response.statusCode}');
    }
  }

  //------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 690));
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text(
            'חפש מאלפי כלבים',
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _areaController,
                  decoration: InputDecoration(
                    labelText: 'חפש לפי איזור',
                    labelStyle: const TextStyle(
                      fontFamily: 'Rubik',
                      color: AppColors.textColor,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      color: AppColors.accentColor,
                      onPressed: () {
                        if (_areaController.text.isNotEmpty) {
                          searchTrainersByAreaa(_areaController.text.trim());
                        } else {
                          setState(() {
                            _showSearchResults = false;
                          });
                        }
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 20.0),
                  ),
                ),
              ),
              if (_showSearchResults) ...[
                _searchResults.isNotEmpty
                    ? Expanded(child: _buildTrainersList(_searchResults))
                    : const Expanded(
                        child: Center(
                            child: Text(
                          "לא נמצאו תוצאות מתאימות",
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                      ),
              ],
              const Divider(height: 20, thickness: 2),
              const Text(
                'כל המאלפים הקיימים כעת במערכת',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              Expanded(child: _buildTrainersList(_trainersList)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainersList(List<dynamic> trainers) {
    return ListView.builder(
      itemCount: trainers.length,
      itemBuilder: (context, index) {
        final trainer = trainers[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: ListTile(
            title: Text(
              "${trainer['FirstName']} ${trainer['LastName']}",
              style: TextStyle(
                fontFamily: 'Rubik',
                color: AppColors.textColor,
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.right,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone,
                        size: 18, color: AppColors.accentColor),
                    const SizedBox(width: 5),
                    Text(
                      "טלפון: ${trainer['PhoneNum']}",
                      style: const TextStyle(
                        fontFamily: 'Alef',
                        color: AppColors.textColor,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 18, color: AppColors.accentColor),
                    const SizedBox(width: 5),
                    Text(
                      "איזור: ${trainer['Area']}",
                      style: const TextStyle(
                        fontFamily: 'Alef',
                        color: AppColors.textColor,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TrainerProfileScreen(
                        trainerData: trainer, token: widget.token)),
              );
            },
          ),
        );
      },
    );
  }
}
