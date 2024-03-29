// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, prefer_const_constructors, must_be_immutable, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter_crm/pages/dashboard_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crm/api/api_interceptors.dart';
import 'package:flutter_crm/storage/user_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

class EndDay extends StatefulWidget {
  @override
  _EndDayState createState() => _EndDayState();
}

class _EndDayState extends State<EndDay> {
  var userProjects = [];
  bool isProjectChosen = false;
  var selectedProjectId;
  bool isAddedTasksLoaded = false;
  bool isTaskSelected = false;
  late FocusNode _textFieldFocusNode;
  bool startedWork = false;
  late Map<String, dynamic> startDayData = {};
  List<dynamic> reports = [];
  String formatSeconds(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    return '$hours h. $minutes min.';
  }

  @override
  void initState() {
    super.initState();
    _textFieldFocusNode = FocusNode();
    initializeDateFormatting('en', null); // Инициализация данных локал
    fetchData();
    checkAddedTasks();
  }

  void dispose() {
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _textHoursController = TextEditingController();
  TextEditingController _textMinutesController =
      TextEditingController(text: '0');
  
  Future<void> fetchData() async {
    try {
      String? userDataString = await UserStorage.getUserData();
      if (userDataString != null) {
        var userData = json.decode(userDataString);
        var userId = userData['id'];
        print(userId);
        var response = await ApiClient.get('users/${userId}/tasks');

        if (response.statusCode == 200) {
          var jsonResponse = json.decode(response.body);

          setState(() {
            userProjects = jsonResponse['data'];
            isAddedTasksLoaded = true;
          });
        } else {
          print(
              'Failed to fetch user data. Status code: ${response.statusCode}');
        }
      } else {
        print('User data is null');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

//FORMAT DATE

  String formatDateString(String dateString) {
    DateTime date = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd MMM', 'en').format(date);

    return formattedDate;
  }

  Future<void> checkAddedTasks() async {
    try {
      var response = await ApiClient.get('work/today');
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] != null) {
          setState(() {
            startDayData = jsonResponse;
            startedWork = true;
          });
          reports = startDayData['data']['reports'];
          print(reports);
        }
      } else {
        print(
            'Failed to fetch today\'s work data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('End day')),
      body: SingleChildScrollView(
        // always adds scroll to avoid overflows
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //ADDED TASKS
                isAddedTasksLoaded
                    ? Container(
                        margin: EdgeInsets.only(bottom: 45),
                        child: reports.isNotEmpty
                            ? Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      'Already added reports:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                              .size
                                              .width),
                                      child: Column(
                                        children: reports.map((item) {
                                          return Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: 5),
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        constraints:
                                                            BoxConstraints(
                                                                maxWidth: 220),
                                                        child: Text(
                                                          '${item['task']['tag']} / ${item['task']['project_name']}  /  ${item['task']['name']}',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          softWrap: false,
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            '${formatDateString(item['date'])} / ${(formatSeconds(item['seconds']))}',
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(), // Преобразуем Iterable в список виджетов
                                      )),
                                ],
                              )
                            : Container(child: SizedBox(height: 11)),
                      )
                    : Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: CircularProgressIndicator(),
                      ),

                //SELECT
                Column(
                  children: [
                    Container(
                        margin: EdgeInsets.only(bottom: 5),
                        child: Text(
                          'Add new report:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    Container(
                      margin: EdgeInsets.only(bottom: 40),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0), // Устанавливаем границу
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text('Select Task'),
                          value: selectedProjectId,
                          onChanged: (String? projectId) {
                            setState(() {
                              selectedProjectId = projectId!;
                              isTaskSelected = true;
                              _textFieldFocusNode.requestFocus();
                            });
                            print(selectedProjectId);
                          },
                          items: userProjects
                              .map<DropdownMenuItem<String>>((project) {
                            return DropdownMenuItem<String>(
                              value: project['id'].toString(),
                              child: Text(project['tag'] +
                                  ' / ' +
                                  project['project']['name'] +
                                  ' / ' +
                                  project['name']),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),

                Visibility(
                  visible: isTaskSelected,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            // Используйте Expanded для первого TextField
                            child: Container(
                              margin: EdgeInsets.only(right: 5, bottom: 10),
                              child: TextField(
                                controller: _textHoursController,
                                focusNode: _textFieldFocusNode,
                                maxLines: 1,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Hours',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            // Используйте Expanded для второго TextField
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: TextField(
                                controller: _textMinutesController,
                                maxLines: 1,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Minutes',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: TextField(
                          controller: _textEditingController,
                          maxLines: 10,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: 'Report',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary:
                                      const Color.fromARGB(255, 1, 77, 139)),
                              child: Text('Cancel',
                                  style: TextStyle(color: Colors.white)),
                              onPressed: () {
                                setState(() {
                                  isTaskSelected = false;
                                });
                              }),
                          ElevatedButton(
                            child: Text('Add report'),
                            onPressed: () async {
                              int hours =
                                  int.tryParse(_textHoursController.text) ?? 0;
                              int minutes =
                                  int.tryParse(_textMinutesController.text) ??
                                      0;
                              int hoursInSeconds = hours * 3600;
                              int minutesInSeconds = minutes * 60;
                              int totalSeconds =
                                  hoursInSeconds + minutesInSeconds;
                              print(
                                  '${_textEditingController} ${selectedProjectId}');
                              print('Total seconds: $totalSeconds');
                              //Get todays date
                              DateTime now = DateTime.now();
                              String formattedDate =
                                  DateFormat('yyyy-MM-dd').format(now);
                              Map<String, dynamic> data = {
                                'date': formattedDate,
                                'report': _textEditingController.text,
                                'seconds': totalSeconds.toString(),
                                'task_id': selectedProjectId
                              };

                              var response =
                                  await ApiClient.post('work/reports', data);

                              if (response.statusCode == 201) {
                                var jsonResponse = json.decode(response.body);
final snackBar = SnackBar(
                                    content: Text('Added!'),
                                    behavior: SnackBarBehavior.floating);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                                print('jsonResponse: $jsonResponse');
                                _textEditingController.clear();
                                _textHoursController.clear();
                                _textMinutesController.clear();
                                isTaskSelected = false;
                                setState(() {
                                  selectedProjectId = null;
                                });
                                checkAddedTasks();
                              } else {
                                print(
                                    'Failed to authenticate. Status code: ${response.statusCode}');
                                print('Response body: ${response.body}');
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Visibility(
                    visible: reports.isNotEmpty && !isTaskSelected,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 1, 77, 139)),
                            onPressed: () async {
                              var response =
                                  await ApiClient.post('work/end', {});

                              if (response.statusCode == 200) {
                                var jsonResponse = json.decode(response.body);

                                print('jsonResponse: $jsonResponse');
                                _textEditingController.clear();
                                _textHoursController.clear();
                                _textMinutesController.clear();
                                isTaskSelected = false;
                                setState(() {
                                  selectedProjectId = null;
                                });
                                checkAddedTasks();
                                print('Day ended');
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen()));
                              } else {
                                print(
                                    'Failed to authenticate. Status code: ${response.statusCode}');
                                print('Response body: ${response.body}');
                              }
                            },
                            child: Text('End Day',
                                style: TextStyle(color: Colors.white))),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
