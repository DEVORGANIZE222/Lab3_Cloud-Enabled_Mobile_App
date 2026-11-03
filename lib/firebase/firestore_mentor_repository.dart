import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/mentor.dart';
import '../models/student.dart';
import '../models/team.dart';
import '../models/view_state.dart';
import '../services/services.dart';

/// Cloud Firestore implementation of [MentorRepository].
///
/// Stores mentor directory in `/mentors/{mentorId}` and team mentorship requests
/// in `/mentor_requests/{requestId}`.
class FirestoreMentorRepository implements MentorRepository {
  FirestoreMentorRepository([FirebaseFirestore? firestore])
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _mentorsCol =>
      _db.collection('mentors');

  CollectionReference<Map<String, dynamic>> get _requestsCol =>
      _db.collection('mentor_requests');

  static final List<Mentor> _defaultMentors = [
    const Mentor(
      id: 'm_thanh',
      fullName: 'Dr. Nguyen Thanh',
      email: 'thanhnt@fpt.edu.vn',
      title: 'Head of AI Lab · Senior Lecturer',
      department: 'Software Engineering',
      expertise: ['AI/ML', 'Computer Vision', 'ROS2', 'Robotics', 'Python'],
      bio: 'Specialises in autonomous UAV navigation, edge AI and computer vision. Supervising Capstone and AI research projects.',
      office: 'Room 304, Alpha Building, Hoa Lac Campus',
      maxQuota: 5,
      currentAssigned: 1,
      mentoredTeamNames: ['Team AI-04'],
    ),
    const Mentor(
      id: 'm_long',
      fullName: 'MSc. Le Hoang Long',
      email: 'longlh@fpt.edu.vn',
      title: 'Lecturer · Blockchain & Distributed Systems',
      department: 'Information Systems',
      expertise: ['Web/Cloud', 'Blockchain', 'Solidity', 'Go', 'Smart Contracts'],
      bio: 'Experienced in FinTech, distributed ledger technologies, and secure decentralized systems.',
      office: 'Room 210, Beta Building, Hoa Lac Campus',
      maxQuota: 4,
      currentAssigned: 1,
      mentoredTeamNames: ['FinTech Guard'],
    ),
    const Mentor(
      id: 'm_chau',
      fullName: 'Dr. Tran Minh Chau',
      email: 'chautm@fpt.edu.vn',
      title: 'Associate Professor · Data Science',
      department: 'Computer Science',
      expertise: ['AI/ML', 'Data Science', 'Recommendation Systems', 'NLP'],
      bio: 'Researching intelligent tutoring systems, recommendation engines and student learning analytics.',
      office: 'Room 402, Alpha Building, Hoa Lac Campus',
      maxQuota: 5,
      currentAssigned: 1,
      mentoredTeamNames: ['EduSmart Analytics'],
    ),
    const Mentor(
      id: 'm_hai',
      fullName: 'MSc. Pham Van Hai',
      email: 'haipv@fpt.edu.vn',
      title: 'Senior Lecturer · Cloud Architecture & DevOps',
      department: 'Software Engineering',
      expertise: ['Web/Cloud', 'AWS', 'Spring Boot', 'Microservices', 'Docker'],
      bio: 'Focusing on cloud native systems, enterprise architectures and smart campus infrastructure.',
      office: 'Room 105, Gamma Building, Hoa Lac Campus',
      maxQuota: 4,
      currentAssigned: 1,
      mentoredTeamNames: ['GreenRoute'],
    ),
    const Mentor(
      id: 'm_ha',
      fullName: 'MSc. Nguyen Thu Ha',
      email: 'hant@fpt.edu.vn',
      title: 'Lecturer · Mobile Development & HCI',
      department: 'Software Engineering',
      expertise: ['Mobile', 'Flutter', 'iOS', 'UI/UX', 'Firebase'],
      bio: 'Industry mentor for mobile product design, cross-platform apps and human-computer interaction.',
      office: 'Room 201, Beta Building, Hoa Lac Campus',
      maxQuota: 3,
      currentAssigned: 1,
      mentoredTeamNames: ['Campus Bite'],
    ),
    const Mentor(
      id: 'm_anh',
      fullName: 'Dr. Vu Quoc Anh',
      email: 'anhvq@fpt.edu.vn',
      title: 'Head of Security Lab · Senior Lecturer',
      department: 'Information Assurance',
      expertise: ['Cybersecurity', 'Network Security', 'Penetration Testing', 'Cloud'],
      bio: 'Guiding projects in zero-trust architectures, vulnerability management and cloud security.',
      office: 'Room 312, Delta Building, Hoa Lac Campus',
      maxQuota: 4,
      currentAssigned: 0,
      mentoredTeamNames: [],
    ),
  ];

  Mentor _mentorFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw const AppFailure('Mentor not found', 'Profile does not exist in directory.', retryable: false);
    }
    return Mentor(
      id: doc.id,
      fullName: data['fullName'] as String? ?? 'Mentor',
      email: data['email'] as String? ?? '',
      title: data['title'] as String? ?? 'Lecturer',
      department: data['department'] as String? ?? 'Software Engineering',
      expertise: List<String>.from(data['expertise'] as List? ?? const []),
      bio: data['bio'] as String? ?? '',
      office: data['office'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String?,
      maxQuota: (data['maxQuota'] as num?)?.toInt() ?? 5,
      currentAssigned: (data['currentAssigned'] as num?)?.toInt() ?? 0,
      mentoredTeamNames: List<String>.from(data['mentoredTeamNames'] as List? ?? const []),
    );
  }

  MentorRequest _requestFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final createdAtRaw = d['createdAt'];
    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : (createdAtRaw is String ? DateTime.tryParse(createdAtRaw) ?? DateTime.now() : DateTime.now());

    return MentorRequest(
      id: doc.id,
      teamId: d['teamId'] as String? ?? '',
      teamName: d['teamName'] as String? ?? '',
      mentorId: d['mentorId'] as String? ?? '',
      mentorName: d['mentorName'] as String? ?? '',
      senderId: d['senderId'] as String? ?? '',
      senderName: d['senderName'] as String? ?? '',
      message: d['message'] as String? ?? '',
      status: MentorRequestStatus.fromString(d['status'] as String?),
      createdAt: createdAt,
      decisionReason: d['decisionReason'] as String?,
    );
  }

  Future<void> ensureSeeded() async {
    try {
      final snap = await _mentorsCol.limit(1).get();
      if (snap.docs.isEmpty) {
        final batch = _db.batch();
        for (final m in _defaultMentors) {
          batch.set(_mentorsCol.doc(m.id), m.toJson());
        }
        await batch.commit();
        debugPrint('Firestore: Seeded initial mentors collection');
      }
    } catch (e) {
      debugPrint('Firestore: Notice - could not auto-seed mentors: $e');
    }
  }

  @override
  Future<List<Mentor>> searchMentors({
    String query = '',
    String? department,
    String? expertise,
    bool availableOnly = false,
  }) async {
    try {
      final snap = await _mentorsCol.get();
      List<Mentor> mentors;
      if (snap.docs.isEmpty) {
        mentors = _defaultMentors;
        // background auto seed if possible
        ensureSeeded();
      } else {
        mentors = snap.docs.map(_mentorFromDoc).toList();
      }

      final q = query.trim().toLowerCase();
      return mentors.where((m) {
        if (availableOnly && !m.isAvailable) return false;
        if (department != null && department.isNotEmpty && m.department != department) {
          return false;
        }
        if (expertise != null && expertise.isNotEmpty &&
            !m.expertise.any((e) => e.toLowerCase() == expertise.toLowerCase())) {
          return false;
        }
        if (q.isNotEmpty) {
          final matches = m.fullName.toLowerCase().contains(q) ||
              m.title.toLowerCase().contains(q) ||
              m.department.toLowerCase().contains(q) ||
              m.bio.toLowerCase().contains(q) ||
              m.expertise.any((e) => e.toLowerCase().contains(q));
          if (!matches) return false;
        }
        return true;
      }).toList();
    } catch (e) {
      debugPrint('Firestore searchMentors error: $e. Falling back to default mentors.');
      return _defaultMentors;
    }
  }

  @override
  Future<Mentor> getMentor(String mentorId) async {
    try {
      final doc = await _mentorsCol.doc(mentorId).get();
      if (!doc.exists) {
        final fallback = _defaultMentors.where((m) => m.id == mentorId).firstOrNull;
        if (fallback != null) return fallback;
        throw const AppFailure('Mentor not found', 'This mentor profile does not exist.', retryable: false);
      }
      return _mentorFromDoc(doc);
    } catch (e) {
      if (e is AppFailure) rethrow;
      final fallback = _defaultMentors.where((m) => m.id == mentorId).firstOrNull;
      if (fallback != null) return fallback;
      throw AppFailure.unexpected(e);
    }
  }

  @override
  Stream<List<Mentor>> watchMentors() {
    return _mentorsCol.snapshots().map((snap) {
      if (snap.docs.isEmpty) return _defaultMentors;
      return snap.docs.map(_mentorFromDoc).toList();
    }).handleError((err) {
      debugPrint('Firestore watchMentors error: $err');
      return _defaultMentors;
    });
  }

  @override
  Future<List<MentorRequest>> getRequestsForTeam(String teamId) async {
    try {
      final snap = await _requestsCol.where('teamId', isEqualTo: teamId).get();
      return snap.docs.map(_requestFromDoc).toList();
    } catch (e) {
      debugPrint('Firestore getRequestsForTeam error: $e');
      return [];
    }
  }

  @override
  Stream<List<MentorRequest>> watchRequestsForTeam(String teamId) {
    return _requestsCol
        .where('teamId', isEqualTo: teamId)
        .snapshots()
        .map((snap) => snap.docs.map(_requestFromDoc).toList())
        .handleError((err) {
      debugPrint('Firestore watchRequestsForTeam error: $err');
      return <MentorRequest>[];
    });
  }

  @override
  Future<List<MentorRequest>> getRequestsForMentor(String mentorId) async {
    try {
      final snap = await _requestsCol.where('mentorId', isEqualTo: mentorId).get();
      final list = snap.docs.map(_requestFromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      debugPrint('Firestore getRequestsForMentor error: $e');
      return [];
    }
  }

  @override
  Stream<List<MentorRequest>> watchRequestsForMentor(String mentorId) {
    return _requestsCol
        .where('mentorId', isEqualTo: mentorId)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map(_requestFromDoc).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        })
        .handleError((err) {
          debugPrint('Firestore watchRequestsForMentor error: $err');
          return <MentorRequest>[];
        });
  }

  @override
  Future<void> respondToRequest({required String requestId, required bool accept, String? reason}) async {
    try {
      final doc = await _requestsCol.doc(requestId).get();
      if (!doc.exists) {
        throw const AppFailure('Request not found', 'This mentorship request no longer exists.');
      }
      final req = _requestFromDoc(doc);
      await _requestsCol.doc(requestId).update({
        'status': accept ? 'approved' : 'rejected',
        'decisionReason': ?reason,
      });

      if (accept) {
        // Assign to team
        await _db.collection('teams').doc(req.teamId).update({
          'supervisor': req.mentorName,
        });
        // Update mentor capacity
        await _mentorsCol.doc(req.mentorId).update({
          'currentAssigned': FieldValue.increment(1),
          'mentoredTeamNames': FieldValue.arrayUnion([req.teamName]),
        });
      }
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw AppFailure('Failed to update request', '$e');
    }
  }

  @override
  Future<List<Team>> getTeamsForMentor(String mentorId, [String? mentorName]) async {
    try {
      final snap = await _db.collection('teams').get();
      final all = <Team>[];
      for (final doc in snap.docs) {
        final d = doc.data();
        final sup = d['supervisor'] as String? ?? '';
        if (mentorName != null && mentorName.isNotEmpty && sup.toLowerCase().contains(mentorName.toLowerCase())) {
          all.add(Team.fromJson({'id': doc.id, ...d}));
        }
      }
      return all;
    } catch (e) {
      debugPrint('Firestore getTeamsForMentor error: $e');
      return [];
    }
  }

  @override
  Future<MentorRequest> requestMentor({
    required String teamId,
    required String teamName,
    required String mentorId,
    required String mentorName,
    required Student sender,
    required String message,
  }) async {
    try {
      // Check existing pending request
      final existingSnap = await _requestsCol
          .where('teamId', isEqualTo: teamId)
          .where('mentorId', isEqualTo: mentorId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (existingSnap.docs.isNotEmpty) {
        throw const AppFailure(
          'Request already sent',
          'Your team already has a pending supervision request to this mentor.',
          retryable: false,
        );
      }

      final docRef = _requestsCol.doc();
      final req = MentorRequest.create(
        id: docRef.id,
        teamId: teamId,
        teamName: teamName,
        mentorId: mentorId,
        mentorName: mentorName,
        sender: sender,
        message: message,
      );

      final data = req.toJson();
      data['createdAt'] = FieldValue.serverTimestamp();

      await docRef.set(data);
      return req;
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw AppFailure('Failed to send request', 'Could not submit mentorship request: $e');
    }
  }

  @override
  Future<void> cancelRequest(String requestId) async {
    try {
      await _requestsCol.doc(requestId).delete();
    } catch (e) {
      throw AppFailure('Cancel failed', 'Could not withdraw request: $e');
    }
  }
}
