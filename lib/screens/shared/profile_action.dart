import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/session_viewmodel.dart';
import '../../widgets/status.dart';

/// App-bar avatar that opens Profile (the only entry to Profile, DV-08).
class ProfileAction extends StatelessWidget {
  const ProfileAction({super.key});

  @override
  Widget build(BuildContext context) {
    final student = context.watch<SessionViewModel>().student;
    return Semantics(
      identifier: 'btn_open_profile',
      child: IconButton(
        tooltip: 'Profile',
        onPressed: () => context.push('/profile'),
        icon: MemberAvatar(initials: student?.initials ?? '?', size: 36),
      ),
    );
  }
}
