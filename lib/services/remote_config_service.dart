abstract class RemoteConfigService {
  Future<void> initialize();
  int get maxTeamMembers;
  bool get enableWaitingPool;
  String get bannerAnnouncement;
}

class FirebaseRemoteConfigService implements RemoteConfigService {
  @override
  Future<void> initialize() async {}

  @override
  int get maxTeamMembers => 5;

  @override
  bool get enableWaitingPool => true;

  @override
  String get bannerAnnouncement => '';
}
