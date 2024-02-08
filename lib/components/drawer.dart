import 'package:flutter/material.dart';
import 'package:flutter_crm/pages/team.dart';
import 'package:flutter_crm/pages/wiki_page.dart';

class CustomDrawer extends StatelessWidget {
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
        ],
      ),
    );
  }
}
