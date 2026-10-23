import 'package:flutter/material.dart';
import '../models/user_model.dart';

/// Lab 2 Component: Member Tile Skeleton
class AppMemberTile extends StatelessWidget {
  final UserModel member;
  final Widget? trailing;

  const AppMemberTile({
    super.key,
    required this.member,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Team implement MemberTile with avatar, name, studentId, and skills
    return ListTile(
      leading: CircleAvatar(child: Text(member.displayName.isNotEmpty ? member.displayName[0] : '?')),
      title: Text(member.displayName),
      subtitle: Text('${member.studentId} • ${member.role}'),
      trailing: trailing,
    );
  }
}
