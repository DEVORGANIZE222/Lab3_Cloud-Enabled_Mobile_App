import 'student.dart';

enum MentorRequestStatus {
  pending('Pending'),
  approved('Approved'),
  rejected('Rejected');

  const MentorRequestStatus(this.label);
  final String label;

  static MentorRequestStatus fromString(String? val) {
    return switch (val?.toLowerCase()) {
      'approved' => MentorRequestStatus.approved,
      'rejected' => MentorRequestStatus.rejected,
      _ => MentorRequestStatus.pending,
    };
  }
}

/// A Capstone supervisor / mentor (lecturer or industry mentor).
class Mentor {
  const Mentor({
    required this.id,
    required this.fullName,
    required this.email,
    required this.title,
    required this.department,
    required this.expertise,
    required this.bio,
    this.office = '',
    this.avatarUrl,
    this.maxQuota = 5,
    this.currentAssigned = 0,
    this.mentoredTeamNames = const [],
  });

  final String id;
  final String fullName;
  final String email;
  final String title;
  final String department;
  final List<String> expertise;
  final String bio;
  final String office;
  final String? avatarUrl;
  final int maxQuota;
  final int currentAssigned;
  final List<String> mentoredTeamNames;

  bool get isAvailable => currentAssigned < maxQuota;
  int get remainingSlots => (maxQuota - currentAssigned).clamp(0, maxQuota);

  String get initials {
    final clean = fullName.replaceAll(
      RegExp(r'^(Dr\.|MSc\.|Prof\.|Assoc\.\s*Prof\.)\s*', caseSensitive: false),
      '',
    );
    final parts = clean.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  factory Mentor.fromJson(Map<String, dynamic> j) => Mentor(
        id: j['id'] as String? ?? '',
        fullName: j['fullName'] as String? ?? '',
        email: j['email'] as String? ?? '',
        title: j['title'] as String? ?? 'Lecturer',
        department: j['department'] as String? ?? 'Software Engineering',
        expertise: List<String>.from(j['expertise'] as List? ?? const []),
        bio: j['bio'] as String? ?? '',
        office: j['office'] as String? ?? '',
        avatarUrl: j['avatarUrl'] as String?,
        maxQuota: (j['maxQuota'] as num?)?.toInt() ?? 5,
        currentAssigned: (j['currentAssigned'] as num?)?.toInt() ?? 0,
        mentoredTeamNames: List<String>.from(j['mentoredTeamNames'] as List? ?? const []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'title': title,
        'department': department,
        'expertise': expertise,
        'bio': bio,
        'office': office,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        'maxQuota': maxQuota,
        'currentAssigned': currentAssigned,
        'mentoredTeamNames': mentoredTeamNames,
      };

  Mentor copyWith({
    String? fullName,
    String? email,
    String? title,
    String? department,
    List<String>? expertise,
    String? bio,
    String? office,
    String? avatarUrl,
    int? maxQuota,
    int? currentAssigned,
    List<String>? mentoredTeamNames,
  }) =>
      Mentor(
        id: id,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        title: title ?? this.title,
        department: department ?? this.department,
        expertise: expertise ?? this.expertise,
        bio: bio ?? this.bio,
        office: office ?? this.office,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        maxQuota: maxQuota ?? this.maxQuota,
        currentAssigned: currentAssigned ?? this.currentAssigned,
        mentoredTeamNames: mentoredTeamNames ?? this.mentoredTeamNames,
      );
}

/// A request sent by a team to a mentor asking for Capstone project supervision.
class MentorRequest {
  const MentorRequest({
    required this.id,
    required this.teamId,
    required this.teamName,
    required this.mentorId,
    required this.mentorName,
    required this.senderId,
    required this.senderName,
    required this.message,
    this.status = MentorRequestStatus.pending,
    required this.createdAt,
    this.decisionReason,
  });

  final String id;
  final String teamId;
  final String teamName;
  final String mentorId;
  final String mentorName;
  final String senderId;
  final String senderName;
  final String message;
  final MentorRequestStatus status;
  final DateTime createdAt;
  final String? decisionReason;

  factory MentorRequest.create({
    required String id,
    required String teamId,
    required String teamName,
    required String mentorId,
    required String mentorName,
    required Student sender,
    required String message,
  }) =>
      MentorRequest(
        id: id,
        teamId: teamId,
        teamName: teamName,
        mentorId: mentorId,
        mentorName: mentorName,
        senderId: sender.id,
        senderName: sender.fullName,
        message: message,
        status: MentorRequestStatus.pending,
        createdAt: DateTime.now(),
      );

  factory MentorRequest.fromJson(Map<String, dynamic> j) => MentorRequest(
        id: j['id'] as String? ?? '',
        teamId: j['teamId'] as String? ?? '',
        teamName: j['teamName'] as String? ?? '',
        mentorId: j['mentorId'] as String? ?? '',
        mentorName: j['mentorName'] as String? ?? '',
        senderId: j['senderId'] as String? ?? '',
        senderName: j['senderName'] as String? ?? '',
        message: j['message'] as String? ?? '',
        status: MentorRequestStatus.fromString(j['status'] as String?),
        createdAt: j['createdAt'] is String
            ? (DateTime.tryParse(j['createdAt'] as String) ?? DateTime.now())
            : DateTime.now(),
        decisionReason: j['decisionReason'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'teamId': teamId,
        'teamName': teamName,
        'mentorId': mentorId,
        'mentorName': mentorName,
        'senderId': senderId,
        'senderName': senderName,
        'message': message,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        if (decisionReason != null) 'decisionReason': decisionReason,
      };

  MentorRequest copyWith({
    MentorRequestStatus? status,
    String? decisionReason,
  }) =>
      MentorRequest(
        id: id,
        teamId: teamId,
        teamName: teamName,
        mentorId: mentorId,
        mentorName: mentorName,
        senderId: senderId,
        senderName: senderName,
        message: message,
        status: status ?? this.status,
        createdAt: createdAt,
        decisionReason: decisionReason ?? this.decisionReason,
      );
}

