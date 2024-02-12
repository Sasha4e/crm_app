// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_crm/api/api_interceptors.dart';
import 'package:flutter_crm/components/drawer.dart';
import 'package:flutter_crm/pages/login_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, dynamic> userData = {'user_name': 'Loading...'};
  bool startedWork = false;
  late Map<String, dynamic> startDayData = {};

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
        await checkWorkDay();
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
            startedWork = true;
          });
          print(startDayData['data']);
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: startedWork
              ? [
                  SizedBox(height: 20),
                  Text(
                    'Hello, ${userData['user_name']}',
                    style: TextStyle(
                        fontSize: 25,
                        color: const Color.fromARGB(255, 1, 61, 32),
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: startDayData['data'] != null
                        ? Text(
                            startedWork
                                ? 'You started your work\n today at ${startDayData['data']['start'].split(' ')[1]}.'
                                : 'Loading... ${startDayData['data']}', // Отображение заглушки пока данные загружаются
                            style: TextStyle(
                                fontSize: 20,
                                color: const Color.fromARGB(255, 56, 21, 8)),
                            textAlign: TextAlign.center,
                          )
                        : Container(), // Индикатор загрузки вместо текста
                  ),
                  if (startDayData['data'] == null)
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          var response = await ApiClient.post('work/start', {});
                          if (response.statusCode == 201) {
                            setState(() {
                              startDayData = json.decode(response.body)['data'];
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
                ]
              : [CircularProgressIndicator()],
        ),
      ),
    );
  }
}
