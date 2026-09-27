import 'package:colorland/coloring/coloring_controller.dart';
import 'package:colorland/screens/home_screen.dart';
import 'package:colorland/theme.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(controllers: await loadControllers()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.controllers});

  final Map<String, ColoringController> controllers;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ColorLand',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: HomeScreen(controllers: controllers),
    );
  }
}
