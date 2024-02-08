import 'package:flutter/material.dart';

class ArticleDetailsPage extends StatefulWidget {
  final String description;
  final String title;

  const ArticleDetailsPage(
      {Key? key, required this.description, required this.title})
      : super(key: key);

  @override
  State<ArticleDetailsPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ArticleDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            widget.description,
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ),
    );
  }
}
