import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/view_state.dart';
import '../../widgets/states.dart';

/// One snackbar format for every failed action: what happened, then what to do.
void showFailure(BuildContext context, AppFailure failure) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${failure.title}. ${failure.cause}')));
}

/// Empty state for team screens opened by a student who has no team.
class NoTeamState extends StatelessWidget {
  const NoTeamState({super.key, this.message = 'Browse teams with open slots and join one before the deadline.'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.group_off_outlined,
      title: "You're not in a team yet",
      message: message,
      actionLabel: 'Browse Teams',
      onAction: () => context.go('/browse'),
    );
  }
}
