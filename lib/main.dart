import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'widgets/state_views.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EXEMatchingApp());
}

class EXEMatchingApp extends StatelessWidget {
  const EXEMatchingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EXEMatching',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppSkeletonHomeScreen(),
    );
  }
}

class AppSkeletonHomeScreen extends StatelessWidget {
  const AppSkeletonHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EXEMatching')),
      body: AppEmptyView(
        icon: Icons.groups_outlined,
        title: '',
        subtitle: 'Hệ thống MVVM, Theme Tokens, Firebase config và các tài liệu chuẩn hóa đã được thiết lập.',
        actionLabel: 'Xem Hướng Dẫn Vibe Coding',
        onAction: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Open file VIBE_CODING_SAFETY_RULES.md để đọc các quy tắc.',
              ),
            ),
          );
        },
      ),
    );
  }
}
