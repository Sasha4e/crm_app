import 'package:flutter/material.dart';

class UserDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  UserDetailsScreen({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userData['name']),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(userData['image']),
              radius: 60,
            ),
            SizedBox(height: 20),
            Text(
              'Name: ${userData['name']}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Username: ${userData['user_name']}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Email: ${userData['email']}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Birthday: ${userData['birthday']}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
