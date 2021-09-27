import 'package:flutter/material.dart';
import 'package:flutter_audio_record/components/theme.dart';
import 'package:flutter_audio_record/views/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: HomeScreen(),
    );
  }
}
