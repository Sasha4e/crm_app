import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_details_screen.dart'; // Импортируйте новый файл
import 'package:shared_preferences/shared_preferences.dart'; // Импортируйте пакет для работы с SharedPreferences

class TeamPage extends StatefulWidget {
  @override
  _TeamPageState createState() => _TeamPageState();
}

class TokenStorage {
  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }
}

class _TeamPageState extends State<TeamPage> {
  late List<dynamic> usersData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    String? accessToken =
        await TokenStorage.getToken(); // Получаем токен из SharedPreferences

    var url = Uri.parse(
        'http://api.stage.newcrm.projects.od.ua/api/users?roles[]=user&roles[]=HR');

    var response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      setState(() {
        usersData = jsonResponse['data'];
      });
    } else {
      print('Failed to fetch users data. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: usersData.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: ListTile(
                title: Text(usersData[index]['name']),
                subtitle: Text(usersData[index]['user_name']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailsScreen(
                        userData: usersData[index],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
