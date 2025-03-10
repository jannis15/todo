import 'package:flutter/material.dart';
import 'package:workout/features/workout/presentation/screens/todo_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(brightness: Brightness.light, seedColor: Colors.teal),
      ),
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: Colors.teal),
      ),
      home: const TodoScreen(),
    );
  }
}
