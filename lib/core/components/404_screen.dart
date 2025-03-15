import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/core/components/buttons.dart';
import 'package:todo/core/components/constrained_scaffold.dart';

class FileNotFoundScreen extends StatelessWidget {
  const FileNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 10,
          children: [
            Text(
              '404 - File not Found',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            TFilledButton(text: 'Go back Home', onPressed: () => context.go('/')),
          ],
        ),
      ),
    );
  }
}
