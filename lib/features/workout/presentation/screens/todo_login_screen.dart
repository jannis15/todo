import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workout/features/settings/data/sources/shared_preferences/settings_service.dart';
import 'package:workout/features/settings/domain/models/settings.dart';
import 'package:workout/features/workout/presentation/components/buttons.dart';
import 'package:workout/features/workout/presentation/screens/todo_register_screen.dart';
import 'package:workout/utils/flutter/utils.dart';

class TodoLoginScreen extends StatefulWidget {
  const TodoLoginScreen({super.key});

  @override
  State<TodoLoginScreen> createState() => _TodoLoginScreenState();
}

class _TodoLoginScreenState extends State<TodoLoginScreen> {
  bool _isObscured = true;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  CancelableOperation? _loginOperation;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      await _loginOperation?.cancel();
      _loginOperation = CancelableOperation.fromFuture(
        Supabase.instance.client.auth.signInWithPassword(email: email, password: password),
      );
      final response = await _loginOperation!.value;
      await SettingsService.saveLoginInformation(
        LoginInformation(email: email, password: password),
      );
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  @override
  void dispose() {
    _loginOperation?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 40, title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.mail),
                label: Text('Email'),
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: _isObscured,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),
                label: const Text('Password'),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                  icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                ),
              ),
            ),
            TFilledButton(onPressed: _login, text: 'Login', loading: _isLoading),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Material(
                  clipBehavior: Clip.antiAlias,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const TodoRegisterScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Create an account',
                        style: textTheme.labelMedium?.copyWith(color: colorScheme.outline),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
