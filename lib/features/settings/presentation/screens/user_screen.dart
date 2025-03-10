import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workout/core/components/buttons.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  CancelableOperation<void>? _signOutOperation;
  bool _isSaving = false;

  @override
  void dispose() {
    _signOutOperation?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 40),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TOutlinedButton(
              iconData: Icons.logout,
              text: 'Logout',
              loading: _isSaving,
              onPressed: () async {
                setState(() {
                  _isSaving = true;
                });
                try {
                  await _signOutOperation?.cancel();
                  _signOutOperation = CancelableOperation.fromFuture(
                    Supabase.instance.client.auth.signOut(),
                  );
                  await _signOutOperation!.value;
                } finally {
                  if (mounted)
                    setState(() {
                      _isSaving = false;
                    });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
