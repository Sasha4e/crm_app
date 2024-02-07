import 'package:flutter/material.dart';
import 'package:flutter_crm/pages/team.dart';
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
      drawer: Drawer(
        backgroundColor: Colors.green[900],
        child: Column(children: [
          DrawerHeader(
              child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Text('CRM',
                style: TextStyle(color: Colors.white, fontSize: 30)),
          )),
          const Padding(
            padding: EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(Icons.home, color: Colors.white),
              title: Text(
                'Dashboard',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(Icons.person, color: Colors.white),
              title: Text(
                'Team',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TeamPage(accessToken: widget.accessToken),
                  ),
                );
              },
            ),
          )
        ]),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text('Hello, ${userData['user_name']}',
                style: TextStyle(fontSize: 20)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: startedWork
                  ? Center(
                      child: Text(
                        'You started your work at\n${startDayData['start']}.\nHave a good day!',
                        style: TextStyle(fontSize: 20, color: Colors.brown),
                        textAlign: TextAlign.center,
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


