import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static Future<String?> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userData');
  }

  static Future<void> clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }

  static Future<void> saveUserData(Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String jsonData = jsonEncode(data);
    await prefs.setString('userData', jsonData);
  }
}
