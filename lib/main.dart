import 'package:flutter/material.dart';
import 'package:flutter_crm/pages/home_screen.dart'; 
import 'package:flutter_crm/pages/login_page.dart';
import 'package:flutter_crm/storage/token_storage.dart'; 
import 'themes/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Authentication App',
      theme: AppTheme.lightTheme,
      home: FutureBuilder<bool>(
        future: _checkToken(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            if (snapshot.data == true) {
              return HomeScreen();
            } else {
              return const LoginPage();
            }
          }
        },
      ),
    );
  }

  Future<bool> _checkToken() async {
    // наличие токена
    String? token = await TokenStorage.getToken();
    return token != null; 
  }
}
