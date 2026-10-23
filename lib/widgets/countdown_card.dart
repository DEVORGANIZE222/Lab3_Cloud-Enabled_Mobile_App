import 'package:flutter/material.dart';

/// Lab 2 Component: Countdown Card Skeleton
class AppCountdownCard extends StatelessWidget {
  final DateTime deadline;

  const AppCountdownCard({
    super.key,
    required this.deadline,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Team implement urgent countdown timer display
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Deadline Countdown Card — Skeleton'),
      ),
    );
  }
}
