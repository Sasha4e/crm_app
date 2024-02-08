import 'package:flutter/material.dart';
import 'package:flutter_crm/pages/login_page.dart';
import 'package:flutter_crm/pages/team_page.dart';
import 'package:flutter_crm/pages/wiki_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';



class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.green[900],
      child: Column(
        children: [
          DrawerHeader(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Text(
                'CRM',
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(Icons.question_mark, color: Colors.white),
              title: Text(
                'Wiki',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WikiPage(),
                  ),
                );
              },
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
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeamPage(),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: SizedBox(), // виджет для разделения
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 16.0),
            child: ListTile(
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                await TokenStorage
                    .clearToken(); // Очистить токен из SharedPreferences
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TokenStorage {
  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  static Future<void> clearToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
  }
}
