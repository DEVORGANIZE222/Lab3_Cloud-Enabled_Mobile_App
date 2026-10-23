import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/remote_config_service.dart';
import '../services/crashlytics_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService authService;
  final StorageService storageService;
  final RemoteConfigService remoteConfigService;
  final CrashlyticsService crashlyticsService;

  ProfileViewModel({
    required this.authService,
    required this.storageService,
    required this.remoteConfigService,
    required this.crashlyticsService,
  });

  // TODO: Team implement Firebase demo actions
}
