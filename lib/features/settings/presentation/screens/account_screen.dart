import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo/core/components/buttons.dart';
import 'package:todo/features/todos/data/repositories/cloud_repository.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
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
      appBar: AppBar(
        toolbarHeight: 40,
        title: const Text('Account Settings'),
        actionsPadding: const EdgeInsets.only(right: 8),
        actions: [
          TOutlinedButton(
            tooltip: 'Logout',
            iconData: Icons.logout,
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
                if (mounted) context.go('/');
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            TFilledButton(
              iconData: Icons.sync,
              text: 'Synchronise',
              highlightType: HighlightType.secondary,
              onPressed: () {
                CloudRepository().syncAllTodos();
              },
            ),
            TFilledButton(
              iconData: Icons.settings_backup_restore,
              text: 'Recover',
              highlightType: HighlightType.secondary,
              onPressed: () {
                CloudRepository().restoreTodos();
              },
            ),
            TFilledButton(
              iconData: Icons.lock,
              text: 'Change password',
              highlightType: HighlightType.secondary,
              onPressed: () {
                context.go('/account/new-password');
              },
            ),
          ],
        ),
      ),
    );
  }
}
