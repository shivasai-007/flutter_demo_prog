import 'package:flutter/material.dart';

import 'screens/todo_home_page.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daymark',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF36B3A9),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF178F86),
          primaryContainer: const Color(0xFFD5F2EE),
          secondary: const Color(0xFFEA705E),
          tertiary: const Color(0xFFB57A16),
          tertiaryContainer: const Color(0xFFFFE9B5),
          surface: const Color(0xFFFFFFFF),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F8F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F8F6),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const TodoHomePage(),
    );
  }
}
