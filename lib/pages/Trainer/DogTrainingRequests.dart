// ignore_for_file: file_names, prefer_typing_uninitialized_variables, non_constant_identifier_names, use_build_context_synchronously
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logging/logging.dart';
import 'package:pinalprojectbark/pages/Trainer/DogProfileScreen.dart';
import 'package:pinalprojectbark/pages/config.dart';
import 'package:pinalprojectbark/design.dart';

final Logger _logger = Logger('ProfilePage');

class DogTrainingRequests extends StatefulWidget {
  final token;
  const DogTrainingRequests({@required this.token, super.key});

  @override
  State<DogTrainingRequests> createState() => _DogTrainingRequestsState();
}

class _DogTrainingRequestsState extends State<DogTrainingRequests> {
  List<dynamic> _RequestsResults = [];
  late String trainerId;

  @override
  void initState() {
    super.initState();
    final jwtDecodedToken = JwtDecoder.decode(widget.token);
    trainerId = (jwtDecodedToken['_id'] as String?)!;
    _RequestsResultsById(trainerId);
  }

  Future<void> _RequestsResultsById(String trainerId) async {
    final String encodedId = Uri.encodeComponent(trainerId);
    final Uri uri = Uri.parse('$requestsResultsById?id=$encodedId');

    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${widget.token}",
      },
    );

    _logger.info('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      setState(() {
        _RequestsResults = jsonResponse['owners'];
      });
    } else {
      _logger.warning(
          'Failed to fetch trainers. Status code: ${response.statusCode}');
    }
  }

  Future<void> rejectTrainingRequest(
      String requestId,
      String ownerId,
      String userName,
      String trainerId,
      String trainerName,
      String dogId,
      String dogName,
      int index) async {
    try {
      final Uri messageUri = Uri.parse(ownerMessages);
      final responseMessage = await http.post(messageUri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${widget.token}",
          },
          body: jsonEncode({
            'OwnerId': ownerId,
            'userName': userName,
            'trainerId': trainerId,
            'trainerName': trainerName,
            'dogId': dogId,
            'dogName': dogName,
            'message': 'בקשת האילוף שלך נדחתה!!',
          }));

      if (responseMessage.statusCode == 200) {
        final Uri deleteUri = Uri.parse('$deleteRequest/$requestId');
        final responseDelete = await http.delete(deleteUri, headers: {
          "Authorization": "Bearer ${widget.token}",
        });

        if (responseDelete.statusCode == 200) {
          setState(() {
            _RequestsResults.removeAt(index);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Request rejected successfully")),
          );
        } else {
          _logger.severe("Failed to delete request: ${responseDelete.body}");
        }
      } else {
        _logger
            .severe("Failed to add rejection message: ${responseMessage.body}");
      }
    } catch (e) {
      _logger.severe("An error occurred: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("An error occurred while processing the request")),
      );
    }
  }

  Future<void> acceptTrainingRequest(
      String requestId,
      String ownerId,
      String userName,
      String trainerId,
      String trainerName,
      String dogId,
      String dogName,
      int index) async {
    try {
      final Uri approveUri = Uri.parse(requestApprove);
      final responseApprove = await http.post(approveUri,
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            'OwnerId': ownerId,
            'userName': userName,
            'trainerId': trainerId,
            'trainerName': trainerName,
            'dogId': dogId,
            'dogName': dogName,
          }));

      if (responseApprove.statusCode == 200) {
        final Uri messageUri = Uri.parse(ownerMessages);
        final responseMessage = await http.post(messageUri,
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer ${widget.token}",
            },
            body: jsonEncode({
              'OwnerId': ownerId,
              'userName': userName,
              'trainerId': trainerId,
              'trainerName': trainerName,
              'dogId': dogId,
              'dogName': dogName,
              'message': 'בקשת האילוף שלך התקבלה !!',
            }));

        if (responseMessage.statusCode == 200) {
          final Uri deleteUri = Uri.parse('$deleteRequest/$requestId');
          final responseDelete = await http.delete(deleteUri, headers: {
            "Authorization": "Bearer ${widget.token}",
          });

          if (responseDelete.statusCode == 200) {
            setState(() {
              _RequestsResults.removeAt(index);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Request accepted successfully")),
            );
          } else {
            _logger.severe("Failed to delete request: ${responseDelete.body}");
          }
        } else {
          _logger.severe(
              "Failed to add acceptance message: ${responseMessage.body}");
        }
      } else {
        _logger.severe("Failed to approve request: ${responseApprove.body}");
      }
    } catch (e) {
      _logger.severe("An error occurred: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("An error occurred while processing the request")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "בקשות חדשות",
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
        ),
        body: SafeArea(
          child: _RequestsResults.isNotEmpty
              ? ListView.builder(
                  itemCount: _RequestsResults.length,
                  itemBuilder: (context, index) {
                    var request = _RequestsResults[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                          color: AppColors.accentColor,
                          width: 1.0,
                        ),
                      ),
                      child: ListTile(
                        key: Key(request['_id']),
                        leading: const Icon(
                          Icons.pets,
                          color: AppColors.accentColor,
                        ),
                        title: Text(
                          'שם הבעלים: ${request['userName'] ?? ''}',
                          style: const TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          'שם הכלב: ${request['dogName'] ?? ''}\nלצפייה לחץ',
                          style: const TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DogProfileScreen(
                                dogId: request['dogId'],
                                token: widget.token,
                              ),
                            ),
                          );
                        },
                        trailing: SizedBox(
                          width: 200,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    acceptTrainingRequest(
                                      request['_id'],
                                      request['OwnerId'],
                                      request['userName'],
                                      request['trainerId'],
                                      request['trainerName'],
                                      request['dogId'],
                                      request['dogName'],
                                      index,
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 8, 177, 64),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: const Text(
                                    "קבל",
                                    style: TextStyle(
                                      fontFamily: 'Alef',
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    rejectTrainingRequest(
                                      request['_id'],
                                      request['OwnerId'],
                                      request['userName'],
                                      request['trainerId'],
                                      request['trainerName'],
                                      request['dogId'],
                                      request['dogName'],
                                      index,
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: const Text(
                                    "דחה",
                                    style: TextStyle(
                                      fontFamily: 'Alef',
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text(
                    "לא נמצאו בקשות",
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
