import 'package:drone_controller/screens/controller_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

const ballSize = 20.0;
const step = 30.0;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'PyiTech',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const ControllerScreen());
  }
}
