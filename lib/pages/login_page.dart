// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_crm/pages/home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UFO engineering',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_usernameController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty) {
                  Map<String, String> data = {
                    'user_name': _usernameController.text,
                    'pass_word': _passwordController.text,
                  };

                  var url = Uri.parse(
                      'http://api.stage.newcrm.projects.od.ua/api/auth/login');

                  var response = await http.post(url, body: data);

                  if (response.statusCode == 200) {
                    var jsonResponse = json.decode(response.body);

                    var accessToken = jsonResponse['access_token'];

                    await TokenStorage.saveToken(
                        accessToken); // Save token to SharedPreferences

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              HomeScreen(accessToken: accessToken)),
                    );

                    print('Access Token: $accessToken');
                  } else {
                    setState(() {
                      isError = true;
                    });

                    print(
                        'Failed to authenticate. Status code: ${response.statusCode}');
                    print('Response body: ${response.body}');
                  }
                }
              },
              child: const Text('Login'),
            ),
            if (isError)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Incorrect login or password',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class TokenStorage {
  static Future<void> saveToken(String token) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('accessToken', token);
  }
}
