import 'package:flutter/material.dart';

class EndDay extends StatefulWidget {
  const EndDay({super.key});

  @override
  State<EndDay> createState() => _EndDayState();
}

class _EndDayState extends State<EndDay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('End day')),
    );
  }
}
