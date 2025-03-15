import 'dart:developer';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo/core/components/buttons.dart';
import 'package:todo/core/components/constrained_scaffold.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  bool _isLoading = false;
  bool _isEnabled = true;
  CancelableOperation<void>? _newPasswordOperation;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _newPasswordOperation?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      title: const Text('Set a new password'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              obscureText: !_isEnabled,
              readOnly: !_isEnabled,
              controller: _passwordController,
              keyboardType: TextInputType.visiblePassword,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock),
                label: Text('Passwort'),
                border: OutlineInputBorder(),
              ),
            ),
            TFilledButton(
              loading: _isLoading,
              onPressed:
                  _isEnabled
                      ? () async {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          final newPassword = _passwordController.text;
                          _newPasswordOperation?.cancel();
                          _newPasswordOperation = CancelableOperation.fromFuture(
                            Supabase.instance.client.auth.updateUser(
                              UserAttributes(password: newPassword),
                            ),
                          );
                          await _newPasswordOperation!.value;
                          if (mounted) {
                            setState(() {
                              _isEnabled = false;
                            });
                          }
                        } finally {
                          if (mounted)
                            setState(() {
                              _isLoading = false;
                            });
                        }
                      }
                      : null,
              text: 'Set password',
            ),
          ],
        ),
      ),
    );
  }
}
