import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workout/features/settings/data/sources/shared_preferences/settings_service.dart';
import 'package:workout/features/settings/domain/models/settings.dart';
import 'package:workout/features/workout/presentation/components/buttons.dart';
import 'package:workout/features/workout/presentation/screens/todo_login_screen.dart';
import 'package:workout/utils/flutter/utils.dart';

class TodoRegisterScreen extends StatefulWidget {
  const TodoRegisterScreen({super.key});

  @override
  State<TodoRegisterScreen> createState() => _TodoRegisterScreenState();
}

class _TodoRegisterScreenState extends State<TodoRegisterScreen> {
  bool _isObscured = true;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reenterPasswordController = TextEditingController();
  CancelableOperation<AuthResponse>? _registerOperation;
  String? _errorText;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final reenterPassword = _reenterPasswordController.text;

    if (password != reenterPassword) {
      setState(() {
        _errorText = 'Re-entered password is not the same!';
      });
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    try {
      await _registerOperation?.cancel();
      _registerOperation = CancelableOperation.fromFuture(
        Supabase.instance.client.auth.signUp(email: email, password: password),
      );
      final response = await _registerOperation!.value;
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
    _registerOperation?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 40, title: const Text('Register')),
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
            TextField(
              controller: _reenterPasswordController,
              obscureText: _isObscured,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),
                label: const Text('Reenter Password'),
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
            if (_errorText != null)
              Text(_errorText!, style: textTheme.bodyMedium?.copyWith(color: colorScheme.error)),
            TFilledButton(onPressed: _login, text: 'Register', loading: _isLoading),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Material(
                  clipBehavior: Clip.antiAlias,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const TodoLoginScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Back to Login',
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
