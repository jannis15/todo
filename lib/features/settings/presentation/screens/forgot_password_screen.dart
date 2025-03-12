import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo/core/components/buttons.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _isLoading = false;
  CancelableOperation<void>? _forgotPasswordOperation;
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _forgotPasswordOperation?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 40, title: const Text('Forgot password?')),
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
            TFilledButton(
              loading: _isLoading,
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                try {
                  final email = _emailController.text.trim();
                  _forgotPasswordOperation?.cancel();
                  _forgotPasswordOperation = CancelableOperation.fromFuture(
                    Supabase.instance.client.auth.resetPasswordForEmail(email),
                  );
                  await _forgotPasswordOperation!.value;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("We've sent you a reset password link!")),
                  );
                } finally {
                  if (mounted)
                    setState(() {
                      _isLoading = false;
                    });
                }
              },
              text: 'Reset password',
            ),
          ],
        ),
      ),
    );
  }
}
