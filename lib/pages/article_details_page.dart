import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

class ArticleDetailsPage extends StatefulWidget {
  final String description;
  final String title;

  const ArticleDetailsPage({
    Key? key,
    required this.description,
    required this.title,
  }) : super(key: key);

  @override
  State<ArticleDetailsPage> createState() => _ArticleDetailsPageState();
}

class _ArticleDetailsPageState extends State<ArticleDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: WebView(
          initialUrl: '',
          onWebViewCreated: (WebViewController webViewController) {
            // При создании веб-представления загружаем HTML-контент
            webViewController.loadUrl(
              Uri.dataFromString(
                widget.description,
                mimeType: 'text/html',
                encoding: Encoding.getByName('utf-8')!,
              ).toString(),
            );
          },
        ),
      ),
    );
  }
}
