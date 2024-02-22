// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_crm/api/api_interceptors.dart';
import 'package:flutter_crm/components/drawer.dart';
import 'package:flutter_crm/pages/end_day_page.dart';
import 'package:flutter_crm/pages/login_page.dart';
import 'package:flutter_crm/storage/user_storage.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, dynamic> userData = {'user_name': 'Loading...'};
  bool startedWork = false;
  late Map<String, dynamic> startDayData = {};
  var formatedStartDayData;
  bool isDayFetched = false;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      var response = await ApiClient.get('auth/me');
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          userData = jsonResponse['data'];
          startedWork = true;
        });
        await UserStorage.saveUserData(userData);
        await checkWorkDay();
        print('UserData: ${UserStorage.getUserData()}');
      } else {
        print('Failed to fetch user data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> checkWorkDay() async {
    try {
      var response = await ApiClient.get('work/today');
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] != null) {
          setState(() {
            startDayData = jsonResponse;
            // Получаем время начала работы и преобразуем в объект DateTime
            DateTime startTime = DateTime.parse(startDayData['data']['start']);
            // Применяем часовой пояс и форматируем время в нужный формат
            startTime = startTime.toLocal();
            String formattedTime = DateFormat('HH:mm').format(startTime);
            // Обновляем startDayData с отформатированным временем
            formatedStartDayData = formattedTime;
            startedWork = true;
          });
          print(startDayData['data']);
        }
        setState(() {
          isDayFetched = true;
        });
      } else {
        isDayFetched = true;
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
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Dashboard',
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [],
      ),
      drawer: CustomDrawer(),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(height: 20),
          if (isDayFetched)
            Text(
              'Hello, ${userData['user_name']}',
              style: TextStyle(
                  fontSize: 25,
                  color: const Color.fromARGB(255, 1, 61, 32),
                  fontWeight: FontWeight.bold),
            ),
          isDayFetched == true
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10.0),
                        child: Column(
                          children: [
                            if (startDayData['data'] != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 45),
                              child: Text(
                                'You started your work\n today at ${formatedStartDayData.toString()}.',
                                style: TextStyle(
                                      fontSize: 20, color: Color(0xFF030332)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (startDayData['data'] != null)
                              startDayData['data']['end'] != null
                                  ? ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          var response = await ApiClient.post(
                                              'work/resume', {});
                                          if (response.statusCode == 200) {
                                            setState(() {
                                              startDayData = json.decode(
                                                  response.body)['data'];
                                            });
                                            var jsonResponse =
                                                json.decode(response.body);
                                            startDayData = jsonResponse['data'];
                                            checkWorkDay();
                                            print('response: ${startDayData}');
                                          } else {
                                            print(
                                                'Failed to fetch user data. Status code: ${response.statusCode}');
                                            print(
                                                'Response body: ${response.body}');
                                          }
                                        } catch (e) {
                                          print('Error: $e');
                                        }
                                      },
                                      child: Text('Resume day'),
                                    )
                                  : ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EndDay()));
                                      },
                                      child: Text('End day'),
                            )
                          ],
                        ),
                      ),
                      if (startDayData['data'] == null)
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              var response =
                                  await ApiClient.post('work/start', {});
                              if (response.statusCode == 201) {
                                setState(() {
                                  startDayData =
                                      json.decode(response.body)['data'];
                                });
                                var jsonResponse = json.decode(response.body);
                                startDayData = jsonResponse['data'];
                                checkWorkDay();
                                print('response: ${startDayData}');
                              } else {
                                print(
                                    'Failed to fetch user data. Status code: ${response.statusCode}');
                                print('Response body: ${response.body}');
                              }
                            } catch (e) {
                              print('Error: $e');
                            }
                          },
                          child: Text('Start day'),
                        ),
                    ],
                  ),
                )
              : CircularProgressIndicator(),
          // : Text('xyinya')
        ]),
      ),
    );
  }
}
