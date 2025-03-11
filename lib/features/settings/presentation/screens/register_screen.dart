import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workout/features/settings/presentation/providers/settings_cubit.dart';
import 'package:workout/features/settings/presentation/states/settings.dart';
import 'package:workout/core/components/buttons.dart';
import 'package:workout/features/settings/presentation/screens/login_screen.dart';
import 'package:workout/core/utils/flutter/utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
                    onTap: () => context.go('/login'),
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
