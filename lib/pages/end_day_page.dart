// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, prefer_const_constructors, must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_crm/api/api_interceptors.dart';
import 'package:flutter_crm/storage/user_storage.dart';

class EndDay extends StatefulWidget {
  @override
  _EndDayState createState() => _EndDayState();
}

class _EndDayState extends State<EndDay> {
  var userProjects = [];
  bool isProjectChosen = false;
  var selectedProjectId;
  bool isTaskSelected = false;
  late FocusNode _textFieldFocusNode;
  bool startedWork = false;
  late Map<String, dynamic> startDayData = {};

  @override
  void initState() {
    super.initState();
    _textFieldFocusNode = FocusNode();
    fetchData();
    checkAddedTasks();
  }

  void dispose() {
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _textHoursController = TextEditingController();

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
          print(startDayData['data']['reports']);
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 40),
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
                    items:
                        userProjects.map<DropdownMenuItem<String>>((project) {
                      return DropdownMenuItem<String>(
                        value: project['id'].toString(),
                        child: Text(project['project']['name'] +
                            ' / ' +
                            project['name']),
                      );
                    }).toList(),
                  ),
                ),
                Visibility(
                  visible: isTaskSelected,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: TextField(
                          controller: _textHoursController,
                          focusNode: _textFieldFocusNode,
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Time',
                            border: OutlineInputBorder(),
                          ),
                        ),
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
                      ElevatedButton(
                        child: Text('Add report'),
                        onPressed: () {
                          print(_textEditingController);
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
