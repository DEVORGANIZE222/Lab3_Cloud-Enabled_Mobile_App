import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'status.dart';

/// "Choose an account" sheet used by the local auth service to mirror the
/// Google account picker. Returns the chosen e-mail, or null when dismissed.
Future<String?> showAccountPicker(BuildContext context, List<({String email, String name})> accounts) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
<<<<<<< HEAD
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(header: true, child: Text('Choose an account', style: context.text.titleLarge)),
              const SizedBox(height: AppSpacing.xs),
              Text('to continue to EXEMatching', style: context.text.bodyMedium),
              const SizedBox(height: AppSpacing.md),
              for (final a in accounts) ...[
                Builder(
                  builder: (ctx) {
                    final isMentor = a.email == 'thanhnt@fpt.edu.vn' ||
                        a.email == 'longlh@fpt.edu.vn' ||
                        a.name.startsWith('Dr.') ||
                        a.name.startsWith('MSc.');
                    final isInvalid = a.email.contains('personal');

                    return Semantics(
                      identifier: 'account_${a.email}',
                      button: true,
                      label: '${a.name}, ${a.email}',
                      excludeSemantics: true,
                      child: ListTile(
                        minTileHeight: 64,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: isMentor
                              ? ctx.colors.primaryContainer
                              : (isInvalid ? ctx.colors.errorContainer : ctx.colors.surfaceContainerHighest),
                          child: Icon(
                            isMentor ? Icons.school : (isInvalid ? Icons.person_off : Icons.person),
                            color: isMentor
                                ? ctx.colors.onPrimaryContainer
                                : (isInvalid ? ctx.colors.onErrorContainer : ctx.colors.primary),
                            size: 20,
                          ),
                        ),
                        title: Text(a.name, style: ctx.text.titleSmall),
                        subtitle: Text(a.email, style: ctx.text.bodySmall),
                        trailing: StatusBadge(
                          label: isMentor ? 'Mentor' : (isInvalid ? 'Invalid' : 'Student'),
                          tone: isMentor ? Tone.primary : (isInvalid ? Tone.neutral : Tone.info),
                        ),
                        onTap: () => Navigator.of(context).pop(a.email),
                      ),
                    );
                  },
=======
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset('assets/brand/logo.png', width: 48, height: 48),
            ),
            const SizedBox(height: AppSpacing.md),
            Semantics(header: true, child: Text('Choose an account', style: context.text.titleLarge)),
            const SizedBox(height: AppSpacing.xs),
            Text('to continue to EXEMatching', style: context.text.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            for (final a in accounts)
              Semantics(
                identifier: 'account_${a.email}',
                button: true,
                label: '${a.name}, ${a.email}',
                excludeSemantics: true,
                child: ListTile(
                  minTileHeight: 64,
                  contentPadding: EdgeInsets.zero,
                  leading: MemberAvatar(initials: a.name.substring(0, 1)),
                  title: Text(a.name),
                  subtitle: Text(a.email),
                  onTap: () => Navigator.of(context).pop(a.email),
>>>>>>> main
                ),
                const Divider(height: 1),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
