import 'package:flutter/material.dart';

/// Lab 2 *App bar*: default (title), with back (nested screens), with actions.
/// Back uses the platform back behaviour, so Android system Back matches it.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key, required this.title, this.actions, this.showBack});

  final String title;
  final List<Widget>? actions;

  /// Null = automatic (shown when the route can pop).
  final bool? showBack;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBack ?? true,
      title: Semantics(header: true, child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)),
      actions: actions,
    );
  }
}
