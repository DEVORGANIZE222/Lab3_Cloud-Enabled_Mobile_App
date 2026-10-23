import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app/providers.dart';
import 'app/router.dart';
import 'theme/app_theme.dart';
import 'viewmodels/session_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await AppServices.create();
  runApp(MultiProvider(providers: services.providers, child: const App()));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = buildRouter(context.read<SessionViewModel>());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EXEMatching',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _router,
    );
  }
}
