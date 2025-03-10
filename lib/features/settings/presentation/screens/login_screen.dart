import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workout/features/settings/presentation/providers/settings_cubit.dart';
import 'package:workout/features/settings/presentation/states/settings.dart';
import 'package:workout/core/components/buttons.dart';
import 'package:workout/features/settings/presentation/screens/forgot_password_screen.dart';
import 'package:workout/features/settings/presentation/screens/register_screen.dart';
import 'package:workout/core/utils/flutter/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscured = true;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  CancelableOperation? _loginOperation;

  @override
  void dispose() {
    _loginOperation?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> login() async {
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
        await context.read<SettingsCubit>().saveLoginInformation(
          LoginInformation(email: email, password: password),
        );
      } finally {
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      }
    }

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
            TFilledButton(onPressed: login, text: 'Login', loading: _isLoading),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 8,
              children: [
                TTransparentButton(
                  text: 'Forgot password?',
                  onPressed:
                      () => Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                  foregroundColor: colorScheme.outline,
                ),
                TTransparentButton(
                  text: 'Create an account',
                  onPressed:
                      () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      ),
                  foregroundColor: colorScheme.outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
