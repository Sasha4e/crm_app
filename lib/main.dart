import 'package:flutter/material.dart';
import 'package:flutter_crm/pages/home_screen.dart';
import 'package:flutter_crm/pages/login_page.dart'; // Предполагается, что у вас есть файл с LoginPage
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? accessToken = await TokenStorage.getToken();
  runApp(MyApp(accessToken: accessToken));
}

class MyApp extends StatelessWidget {
  final String? accessToken;

  const MyApp({Key? key, this.accessToken}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Authentication App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: accessToken != null
          ? HomeScreen(accessToken: accessToken!)
          : LoginPage(),
    );
  }
}

class TokenStorage {
  static Future<String?> getToken() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }
}
