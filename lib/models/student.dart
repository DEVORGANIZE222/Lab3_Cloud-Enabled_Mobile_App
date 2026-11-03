/// A signed-in user (Student or Mentor).
class Student {
  const Student({
    required this.id,
    required this.email,
    required this.fullName,
    required this.studentCode,
    required this.major,
    required this.cohort,
    this.skills = const [],
    this.preferredRoles = const [],
    this.role = 'student',
    this.mentorId,
  });

  final String id;
  final String email;
  final String fullName;
  final String studentCode;
  final String major;
  final String cohort;
  final List<String> skills;
  final List<String> preferredRoles;
  final String role;
  final String? mentorId;

  bool get isMentor => role == 'mentor' || mentorId != null;

  String get firstName => fullName.split(' ').first;

  String get initials {
    final clean = fullName.replaceAll(
      RegExp(r'^(Dr\.|MSc\.|Prof\.|Assoc\.\s*Prof\.)\s*', caseSensitive: false),
      '',
    );
    final parts = clean.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  factory Student.fromJson(Map<String, dynamic> j) => Student(
    id: j['id'] as String,
    email: j['email'] as String,
    fullName: j['fullName'] as String,
    studentCode: j['studentCode'] as String? ?? '',
    major: j['major'] as String? ?? '',
    cohort: j['cohort'] as String? ?? '',
    skills: List<String>.from(j['skills'] as List? ?? const []),
    preferredRoles: List<String>.from(j['preferredRoles'] as List? ?? const []),
    role: j['role'] as String? ?? 'student',
    mentorId: j['mentorId'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'studentCode': studentCode,
    'major': major,
    'cohort': cohort,
    'skills': skills,
    'preferredRoles': preferredRoles,
    'role': role,
    if (mentorId != null) 'mentorId': mentorId,
  };
}
