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
  var isProjectChosen = false;
  var selectedProjectId;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

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
          print(jsonResponse['data']);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('End day')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text('Select Project'),
                value: selectedProjectId,
                onChanged: (String? projectId) {
                  setState(() {
                    selectedProjectId = projectId!;
                  });
                },
                selectedItemBuilder: (BuildContext context) {
                  return userProjects.map<Widget>((project) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width -
                          40, // устанавливаем желаемую ширину
                      child: Text(
                        project['project']['name'],
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList();
                },
                items: userProjects.map<DropdownMenuItem<String>>((project) {
                  return DropdownMenuItem<String>(
                    value: project['id'].toString(),
                    child: Text(
                        project['project']['name'] + ' / ' + project['name']),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Действие, которое должно произойти при выборе проекта
                print('Выбран проект с id: $selectedProjectId');
              },
              child: Text('Select'),
            ),
          ],
        ),
      ),
    );
  }
}
