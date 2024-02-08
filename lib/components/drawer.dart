// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_crm/pages/login_page.dart';
import 'package:flutter_crm/pages/team_page.dart';
import 'package:flutter_crm/pages/wiki_page.dart';
import 'package:flutter_crm/storage/token_storage.dart';


class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFF030332),
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
            child: SizedBox(), 
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
                    .clearToken(); 
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

