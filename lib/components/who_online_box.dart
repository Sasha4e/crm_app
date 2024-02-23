import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_crm/api/api_interceptors.dart';

class WhoOnline extends StatefulWidget {
  const WhoOnline({super.key});

  @override
  State<WhoOnline> createState() => WhoOnlineState();
}

class WhoOnlineState extends State<WhoOnline> {
  int onlineCount = 0;
  var usersOnline = [];
  void initState() {
    super.initState();
    getOnlineUsers();
  }

  Future<void> getOnlineUsers() async {
    try {
      var response = await ApiClient.get('users/online');
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          usersOnline = jsonResponse['data'];
          onlineCount = usersOnline.length;
        });

        print('usersOnline: $usersOnline');
      } else {
        print('Failed to fetch user data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('who is online ($onlineCount)'),
        Container(
            width: 300,
            height: 100,
            padding: EdgeInsets.all(10),
            // alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF030332), width: 1),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: usersOnline.map((item) {
                return Text(
                  "${item['nickname'].toString()}, ",
                  textAlign: TextAlign.start,
                );
              }).toList(),
            )),
      ],
    );
  }
}
