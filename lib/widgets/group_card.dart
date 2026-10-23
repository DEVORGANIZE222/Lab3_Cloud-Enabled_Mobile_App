import 'package:flutter/material.dart';
import '../models/team_model.dart';

/// Lab 2 Component: Group Card Skeleton
class AppGroupCard extends StatelessWidget {
  final TeamModel team;
  final VoidCallback? onTap;

  const AppGroupCard({
    super.key,
    required this.team,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Team implement GroupCard design tokens (radius 12, padding 16, border)
    return Card(
      child: ListTile(
        title: Text(team.name),
        subtitle: Text(team.topic),
        trailing: Text('${team.memberIds.length}/${team.maxMembers} slots'),
        onTap: onTap,
      ),
    );
  }
}
