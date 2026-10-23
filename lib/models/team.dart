import 'student.dart';

/// FPT Capstone rule (Lab 2 persona and DESIGN.md): a team locks with 4–5 members.
abstract final class TeamRules {
  static const int minMembers = 4;
  static const int maxMembers = 5;
}

class TeamMember {
  const TeamMember({
    required this.studentId,
    required this.fullName,
    required this.studentCode,
    required this.role,
    this.skills = const [],
  });

  final String studentId;
  final String fullName;
  final String studentCode;
  final String role;
  final List<String> skills;

  String get initials {
    final p = fullName.trim().split(RegExp(r'\s+'));
    return p.length == 1 ? p.first[0].toUpperCase() : (p.first[0] + p.last[0]).toUpperCase();
  }

  factory TeamMember.fromStudent(Student s, String role) =>
      TeamMember(studentId: s.id, fullName: s.fullName, studentCode: s.studentCode, role: role, skills: s.skills);

  factory TeamMember.fromJson(Map<String, dynamic> j) => TeamMember(
    studentId: j['studentId'] as String,
    fullName: j['fullName'] as String,
    studentCode: j['studentCode'] as String,
    role: j['role'] as String,
    skills: List<String>.from(j['skills'] as List? ?? const []),
  );
}

/// A Capstone team. Derived getters only; the rules that change state live in
/// the repository and ViewModels.
class Team {
  const Team({
    required this.id,
    required this.code,
    required this.name,
    required this.topic,
    required this.description,
    required this.category,
    required this.tags,
    required this.members,
    required this.openRoles,
    required this.supervisor,
    this.capacity = TeamRules.maxMembers,
    this.leaderId,
    this.votes = const {},
    this.locked = false,
    this.lockCode,
    this.lockedAt,
    this.invitesSent = 0,
  });

  final String id;

  /// Short code shown in the UI, e.g. "AI-04".
  final String code;

  /// Display name, e.g. "Team AI-04" or "FinTech Guard".
  final String name;
  final String topic;
  final String description;
  final String category;
  final List<String> tags;
  final List<TeamMember> members;
  final List<String> openRoles;
  final String supervisor;
  final int capacity;
  final String? leaderId;

  /// voterId → candidateId.
  final Map<String, String> votes;
  final bool locked;
  final String? lockCode;
  final DateTime? lockedAt;
  final int invitesSent;

  int get memberCount => members.length;
  int get openSlots => (capacity - memberCount).clamp(0, capacity);
  bool get isFull => openSlots == 0;
  bool get meetsSizeRule => memberCount >= TeamRules.minMembers && memberCount <= TeamRules.maxMembers;
  bool get hasLeader => leaderId != null;
  bool isMember(String studentId) => members.any((m) => m.studentId == studentId);

  TeamMember? get leader => members.where((m) => m.studentId == leaderId).firstOrNull;

  int votesFor(String candidateId) => votes.values.where((c) => c == candidateId).length;

  /// A leader is elected by more than half of the current members
  /// (Lab 2 Flow 2: 3 votes in a 4–5 member team).
  int get votesNeeded => memberCount ~/ 2 + 1;

  Team copyWith({
    List<TeamMember>? members,
    String? leaderId,
    bool clearLeader = false,
    Map<String, String>? votes,
    bool? locked,
    String? lockCode,
    DateTime? lockedAt,
    int? invitesSent,
    List<String>? openRoles,
  }) {
    return Team(
      id: id,
      code: code,
      name: name,
      topic: topic,
      description: description,
      category: category,
      tags: tags,
      members: members ?? this.members,
      openRoles: openRoles ?? this.openRoles,
      supervisor: supervisor,
      capacity: capacity,
      leaderId: clearLeader ? null : (leaderId ?? this.leaderId),
      votes: votes ?? this.votes,
      locked: locked ?? this.locked,
      lockCode: lockCode ?? this.lockCode,
      lockedAt: lockedAt ?? this.lockedAt,
      invitesSent: invitesSent ?? this.invitesSent,
    );
  }

  factory Team.fromJson(Map<String, dynamic> j) => Team(
    id: j['id'] as String,
    code: j['code'] as String,
    name: j['name'] as String,
    topic: j['topic'] as String,
    description: j['description'] as String,
    category: j['category'] as String,
    tags: List<String>.from(j['tags'] as List),
    members: [for (final m in j['members'] as List) TeamMember.fromJson(m as Map<String, dynamic>)],
    openRoles: List<String>.from(j['openRoles'] as List? ?? const []),
    supervisor: j['supervisor'] as String,
    capacity: j['capacity'] as int? ?? TeamRules.maxMembers,
    leaderId: j['leaderId'] as String?,
    votes: Map<String, String>.from(j['votes'] as Map? ?? const {}),
    locked: j['locked'] as bool? ?? false,
  );
}

/// Filters on Browse (Lab 2 SCR_03 chips).
enum TeamFilter {
  openSlots('Open Slots'),
  aiMl('AI/ML'),
  mobile('Mobile'),
  webCloud('Web/Cloud');

  const TeamFilter(this.label);
  final String label;
}
