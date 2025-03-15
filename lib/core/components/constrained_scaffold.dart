import 'package:flutter/material.dart';
import 'package:todo/config/config.dart';

class ConstrainedScaffold extends StatelessWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? body;
  final Widget? floatingActionButton;

  const ConstrainedScaffold({
    super.key,
    this.title,
    this.actions,
    this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          (title == null && actions == null)
              ? null
              : AppBar(
                leading: const SizedBox(),
                leadingWidth: 0,
                toolbarHeight: 40,
                titleSpacing: 0,
                title: Center(
                  child: SizedBox(
                    width: AppSizes.kDesktopWidth,
                    child: Row(
                      spacing: 8,
                      children: [
                        const SizedBox(),
                        Expanded(
                          child: Row(
                            spacing: 8,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (title != null || Navigator.of(context).canPop())
                                Expanded(
                                  child: Row(
                                    spacing: 8,
                                    children: [
                                      if (Navigator.of(context).canPop())
                                        IconButton(
                                          tooltip: 'Back',
                                          icon: const Icon(Icons.arrow_back),
                                          onPressed: () {
                                            Navigator.of(context).maybePop();
                                          },
                                        ),
                                      if (title != null) Flexible(child: title!),
                                    ],
                                  ),
                                ),
                              if (actions != null) ...actions!,
                            ],
                          ),
                        ),
                        const SizedBox(),
                      ],
                    ),
                  ),
                ),
              ),
      body:
          (body != null || floatingActionButton != null)
              ? Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: AppSizes.kDesktopWidth,
                  child: Stack(
                    children: [
                      if (body != null) body!,
                      if (floatingActionButton != null)
                        Positioned(bottom: 8, right: 8, child: floatingActionButton!),
                    ],
                  ),
                ),
              )
              : null,
    );
  }
}
