// ignore_for_file: unnecessary_type_check, prefer_const_constructors, unnecessary_brace_in_string_interps, avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TokenStorage {
  static String? token;
}

class HomeScreen extends StatefulWidget {
  final String accessToken;

  HomeScreen({required this.accessToken});

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
    var url = Uri.parse('http://api.stage.newcrm.projects.od.ua/api/auth/me');

    var response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${widget.accessToken}'},
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      setState(() {
        userData = jsonResponse['data'];

        print('Type of userData: ${userData.runtimeType}');
      });
    } else {
      print('Failed to fetch user data. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'DASHBOARD',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You have successfully logged in!'),
            SizedBox(height: 20),
            Text('Hello, ${userData['user_name']}',
                style: TextStyle(
                  fontSize: 20,
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: startedWork
                  ? Center(
                      child: Center(
                        child: Text(
                          'You started your work at ${startDayData['start']}. Have a good day!',
                          style: TextStyle(fontSize: 20, color: Colors.brown),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        var url = Uri.parse(
                            'http://api.stage.newcrm.projects.od.ua/api/work/start');
                        var response = await http.post(url, headers: {
                          'Authorization': 'Bearer ${widget.accessToken}'
                        });
                        if (response.statusCode == 201) {
                          setState(() {
                            startedWork = true;
                          });
                          var jsonResponse = json.decode(response.body);
                          startDayData = jsonResponse['data'];
                          print('response: ${startDayData}');
                        } else {
                          print(
                              'Failed to fetch user data. Status code: ${response.statusCode}');
                          print('Response body: ${response.body}');
                        }
                      },
                      child: Text('Start day'),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
