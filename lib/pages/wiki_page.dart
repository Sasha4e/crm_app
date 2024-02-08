// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_crm/api/api_interceptors.dart';
import 'package:flutter_crm/pages/article_details_page.dart';

class WikiPage extends StatefulWidget {
  const WikiPage({Key? key}) : super(key: key);

  @override
  State<WikiPage> createState() => _WikiPageState();
}

class _WikiPageState extends State<WikiPage> {
  late List<dynamic> wikiData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var response = await ApiClient.get('wiki-pages');

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      setState(() {
        wikiData = jsonResponse['data'];
      });
      print('$wikiData');
    } else {
      print('Failed to fetch users data. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wiki'),
      ),
      body: ListView.builder(
        itemCount: wikiData.length,
        itemBuilder: (BuildContext context, int index) {
          final article = wikiData[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetailsPage(
                      description: article['description'],
                      title: article['title']),
                ),
              );
            },
            child: ListTile(
              leading: Icon(
                Icons.library_books,
                color: Colors.grey,
              ),
              title: Text(article['title'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              subtitle: Text(article['author']['user_name']
                  .toString()), // или любое другое поле для отображения
            ),
          );
        },
      ),
    );
  }
}
