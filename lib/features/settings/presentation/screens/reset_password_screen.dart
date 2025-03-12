import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo/core/components/buttons.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
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
              loading: !(_forgotPasswordOperation?.isCompleted ?? true),
              onPressed: () async {
                final email = _emailController.text.trim();
                _forgotPasswordOperation?.cancel();
                _forgotPasswordOperation = CancelableOperation.fromFuture(
                  Supabase.instance.client.auth.resetPasswordForEmail(email),
                );
                if (mounted) setState(() {});
                await _forgotPasswordOperation!.value;
                if (mounted) setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("We've sent you a reset password link!")),
                );
              },
              text: 'Reset password',
            ),
          ],
        ),
      ),
    );
  }
}
