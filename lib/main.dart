import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workout/features/settings/presentation/providers/settings_cubit.dart';
import 'package:workout/features/todos/presentation/screens/todo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  final settingsService = SettingsCubit();
  await settingsService.loadSettings();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  if (!settingsService.state.isLoginInformationEmpty) {
    await Supabase.instance.client.auth.signInWithPassword(
      password: settingsService.state.password,
      email: settingsService.state.email,
    );
  }

  runApp(MyApp(settingsService: settingsService));
}

class MyApp extends StatelessWidget {
  final SettingsCubit _settingsService;

  const MyApp({super.key, required SettingsCubit settingsService})
    : _settingsService = settingsService;

  @override
  Widget build(BuildContext context) {
    ThemeData getThemeData({required Brightness brightness}) => ThemeData.from(
      colorScheme: ColorScheme.fromSeed(brightness: brightness, seedColor: Colors.teal),
    );

    return BlocProvider<SettingsCubit>.value(
      value: _settingsService,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: getThemeData(brightness: Brightness.light),
        darkTheme: getThemeData(brightness: Brightness.dark),
        home: const TodoScreen(),
      ),
    );
  }
}
