import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workout/features/settings/data/sources/shared_preferences/settings_service.dart';
import 'package:workout/features/workout/presentation/screens/todo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  final settings = await SettingsService.loadSettings();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  if (!settings.isLoginInformationEmpty) {
    await Supabase.instance.client.auth.signInWithPassword(
      password: settings.password,
      email: settings.email,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData getThemeData({required Brightness brightness}) => ThemeData.from(
      colorScheme: ColorScheme.fromSeed(brightness: brightness, seedColor: Colors.teal),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: getThemeData(brightness: Brightness.light),
      darkTheme: getThemeData(brightness: Brightness.dark),
      home: const TodoScreen(),
    );
  }
}
