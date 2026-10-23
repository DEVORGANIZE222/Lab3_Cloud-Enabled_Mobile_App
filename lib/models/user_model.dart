/// Model for ExeMatching Student User
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String studentId;
  final String role;
  final String? currentTeamId;
  final List<String> skills;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.studentId,
    this.role = 'Member',
    this.currentTeamId,
    this.skills = const [],
  });

  bool get hasTeam => currentTeamId != null && currentTeamId!.isNotEmpty;
}
