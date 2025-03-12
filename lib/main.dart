import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workout/features/settings/presentation/providers/settings_cubit.dart';
import 'package:workout/features/settings/presentation/screens/account_screen.dart';
import 'package:workout/features/settings/presentation/screens/forgot_password_screen.dart';
import 'package:workout/features/settings/presentation/screens/login_screen.dart';
import 'package:workout/features/settings/presentation/screens/new_password_screen.dart';
import 'package:workout/features/settings/presentation/screens/register_screen.dart';
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
  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const TodoScreen(),
        routes: [
          GoRoute(path: '/new-password', builder: (_, __) => const NewPasswordScreen()),
          GoRoute(
            path: '/account',
            builder: (_, __) => const AccountScreen(),
            routes: [GoRoute(path: '/new-password', builder: (_, __) => const NewPasswordScreen())],
          ),
          GoRoute(
            path: '/login',
            builder: (_, __) => const LoginScreen(),
            routes: [
              GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
            ],
          ),
          GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        ],
      ),
    ],
  );

  MyApp({super.key, required SettingsCubit settingsService}) : _settingsService = settingsService;

  @override
  Widget build(BuildContext context) {
    ThemeData getThemeData({required Brightness brightness}) => ThemeData.from(
      colorScheme: ColorScheme.fromSeed(brightness: brightness, seedColor: Colors.teal),
    );

    return BlocProvider<SettingsCubit>.value(
      value: _settingsService,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: getThemeData(brightness: Brightness.light),
        darkTheme: getThemeData(brightness: Brightness.dark),
        routerConfig: _router,
      ),
    );
  }
}
