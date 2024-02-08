// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_crm/components/drawer.dart';
import 'package:flutter_crm/pages/login_page.dart';
import 'package:flutter_crm/pages/team_page.dart';
import 'package:flutter_crm/pages/wiki_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }
}

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
    checkWorkDay();
    fetchData();
  }

  Future<void> checkWorkDay() async {
    String? accessToken = await TokenStorage.getToken();
    var todayWorkUrl =
        Uri.parse('http://api.stage.newcrm.projects.od.ua/api/work/today');
    var response = await http.get(
      todayWorkUrl,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        setState(() {
          startedWork = true;
          startDayData = jsonResponse;
        });
        print(startDayData['data']['start']);
      }
    } else {
      print(
          'Failed to fetch today\'s work data. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> fetchData() async {
    String? accessToken = await TokenStorage.getToken();
    var userDataUrl =
        Uri.parse('http://api.stage.newcrm.projects.od.ua/api/auth/me');
    var response = await http.get(
      userDataUrl,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      setState(() {
        userData = jsonResponse['data'];
      });
    } else {
      print('Failed to fetch user data. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'DASHBOARD',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
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
          children: [
            SizedBox(height: 20),
            Text('Hello, ${userData['user_name']}',
                style: TextStyle(
                    fontSize: 25,
                    color: const Color.fromARGB(255, 1, 61, 32),
                    fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: startedWork
                  ? Center(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              'You started your work\n today at ${startDayData['data']['start'].split(' ')[1]}.',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: const Color.fromARGB(255, 56, 21, 8)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Text('Have a good day!',
                              style: TextStyle(
                                  fontSize: 25,
                                  color: const Color.fromARGB(255, 1, 61, 32),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        String? accessToken = await TokenStorage.getToken();
                        var url = Uri.parse(
                            'http://api.stage.newcrm.projects.od.ua/api/work/start');
                        var response = await http.post(url,
                            headers: {'Authorization': 'Bearer $accessToken'});
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
